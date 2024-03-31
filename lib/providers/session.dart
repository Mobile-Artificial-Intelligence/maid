import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:langchain/langchain.dart';
import 'package:maid/classes/large_language_model.dart';
import 'package:maid/classes/llama_cpp_model.dart';
import 'package:maid/classes/mistral_ai_model.dart';
import 'package:maid/classes/ollama_model.dart';
import 'package:maid/classes/open_ai_model.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/providers/user.dart';
import 'package:maid/static/logger.dart';
import 'package:maid/classes/chat_node.dart';
import 'package:maid/static/utilities.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Session extends ChangeNotifier {
  Key _key = UniqueKey();
  bool _busy = false;
  LargeLanguageModel model = LlamaCppModel();
  ChatNode _root = ChatNode(key: UniqueKey());
  ChatNode? _tail;
  String _messageBuffer = "";

  bool get isBusy => _busy;

  String get rootMessage {
    final message = getFirstUserMessage();
    if (message != null) {
      _root.message = message;
    }
    return _root.message;
  }

  ChatNode get root => _root;

  ChatNode? get tail => _tail;

  Key get key => _key;

  set busy(bool value) {
    _busy = value;
    notifyListeners();
  }

  void init() async {
    Logger.log("Session Initialised");

    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastSession =
        json.decode(prefs.getString("last_session") ?? "{}") ?? {};

    if (lastSession.isNotEmpty) {
      fromMap(lastSession);
    } else {
      newSession();
    }
  }

  void notify() {
    notifyListeners();
  }

  Session() {
    newSession();
  }

  Session.fromMap(Map<String, dynamic> inputJson) {
    fromMap(inputJson);
  }

  void newSession() {
    final key = UniqueKey();
    _root = ChatNode(key: key);
    _root.message = "New Chat";
    _tail = null;
    model = LlamaCppModel();
    notifyListeners();
  }

  Session copy() {
    final session = Session();
    session.from(this);
    return session;
  }

  void from(Session session) {
    _key = session.key;
    _root = session.root;
    _tail = session.tail;
    model = session.model;
    notifyListeners();
  }

  void fromMap(Map<String, dynamic> inputJson) {
    _root = ChatNode.fromMap(inputJson['root']);
    _tail = _root.findTail();

    final type = AiPlatformType.values[inputJson['llm_type'] ?? AiPlatformType.llamacpp.index];

    switch (type) {
      case AiPlatformType.llamacpp:
        switchLlamaCpp();
        break;
      case AiPlatformType.openAI:
        switchOpenAI();
        break;
      case AiPlatformType.ollama:
        switchOllama();
        break;
      case AiPlatformType.mistralAI:
        switchMistralAI();
        break;
      default:
        switchLlamaCpp();
        break;
    }
    
    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    return {
      'root': _root.toMap(),
      'llm_type': model.type.index,
      'model': model.toMap(),
    };
  }

  String getMessage(Key key) {
    return _root.find(key)?.message ?? "";
  }

  String? getFirstUserMessage() {
    var current = _root;
    while (current.currentChild != null) {
      current = current.find(current.currentChild!)!;
      if (current.userGenerated) {
        return current.message;
      }
    }
    return null;
  }

  void setRootMessage(String message) {
    _root.message = message;
    notifyListeners();
  }

  void prompt(BuildContext context) async {
    _busy = true;
    notifyListeners();

    final user = context.read<User>();
    final character = context.read<Character>();

    List<ChatMessage> chatMessages = [];

    final description = Utilities.formatPlaceholders(character.description, user.name, character.name);
    final personality = Utilities.formatPlaceholders(character.personality, user.name, character.name);
    final scenario = Utilities.formatPlaceholders(character.scenario, user.name, character.name);
    final system = Utilities.formatPlaceholders(character.system, user.name, character.name);

    final preprompt = '$description\n\n$personality\n\n$scenario\n\n$system';

    List<Map<String, dynamic>> messages = [
      {
        'role': 'system',
        'content': preprompt,
      }
    ];

    if (character.useExamples) {
      messages.addAll(character.examples);
    }

    messages.addAll(getMessages());

    for (var message in messages) {
      print(message);

      switch (message['role']) {
        case "user":
          chatMessages.add(ChatMessage.humanText(message['content']));
          chatMessages.add(ChatMessage.system(Utilities.formatPlaceholders(
          character.system, user.name, character.name)));
          break;
        case "assistant":
          chatMessages.add(ChatMessage.ai(message['content']));
          break;
        case "system": // Under normal circumstances, this should never be called
          chatMessages.add(ChatMessage.system(message['content']));
          break;
        default:
          break;
      }
    }

    Logger.log("Prompting with ${model.type.name}");

    final stringStream = model.prompt(chatMessages);

    await for (var message in stringStream) {
      stream(message);
    }

    _busy = false;
    finalise();
    notifyListeners();
  }

  void regenerate(Key key, BuildContext context) {
    var parent = _root.getParent(key);
    if (parent == null) {
      return;
    } else {
      parent.currentChild = null;
      _tail = _root.findTail();
      add(UniqueKey(), userGenerated: false);
      notifyListeners();
      prompt(context);
    }
  }

  void edit(Key key, String message, BuildContext context) {
    var parent = _root.getParent(key);
    if (parent != null) {
      parent.currentChild = null;
      _tail = _root.findTail();
    }
    add(UniqueKey(), userGenerated: true, message: message);
    add(UniqueKey(), userGenerated: false);
    notifyListeners();
    prompt(context);
  }

  void stop() {
    (model as LlamaCppModel).stop();
    _busy = false;
    Logger.log('Local generation stopped');
    finalise();
    notifyListeners();
  }

  void add(Key key,
      {String message = "",
      bool userGenerated = false,
      bool notify = true}) {
    final node = ChatNode(key: key, message: message, userGenerated: userGenerated);

    var found = _root.find(key);
    if (found != null) {
      found.message = message;
    } 
    else {
      _tail ??= _root.findTail();

      _tail!.children.add(node);
      _tail!.currentChild = key;
      _tail = _tail!.findTail();
    }

    if (notify) {
      notifyListeners();
    }
  }

  void remove(Key key) {
    var parent = _root.getParent(key);
    if (parent != null) {
      parent.children.removeWhere((element) => element.key == key);
      _tail = _root.findTail();
    }
    notifyListeners();
  }

  void stream(String? message) async {
    if (message == null) {
      finalise();
    } else {
      _messageBuffer += message;
      _tail ??= _root.findTail();

      if (!(_tail!.messageController.isClosed)) {
        _tail!.messageController.add(_messageBuffer);
        _messageBuffer = "";
      }

      _tail!.message += message;
    }
  }

  void finalise() {
    _busy = false;

    _tail ??= _root.findTail();

    if (!(_tail!.finaliseController.isClosed)) {
      _tail!.finaliseController.add(0);
    }

    notifyListeners();
  }

  void next(Key key) {
    var parent = _root.getParent(key);
    if (parent != null) {
      if (parent.currentChild == null) {
        parent.currentChild = key;
      } else {
        var currentChildIndex = parent.children
            .indexWhere((element) => element.key == parent.currentChild);
        if (currentChildIndex < parent.children.length - 1) {
          parent.currentChild = parent.children[currentChildIndex + 1].key;
          _tail = _root.findTail();
        }
      }
    }

    notifyListeners();
  }

  void last(Key key) {
    var parent = _root.getParent(key);
    if (parent != null) {
      if (parent.currentChild == null) {
        parent.currentChild = key;
      } else {
        var currentChildIndex = parent.children
            .indexWhere((element) => element.key == parent.currentChild);
        if (currentChildIndex > 0) {
          parent.currentChild = parent.children[currentChildIndex - 1].key;
          _tail = _root.findTail();
        }
      }
    }

    notifyListeners();
  }

  int siblingCount(Key key) {
    var parent = _root.getParent(key);
    if (parent != null) {
      return parent.children.length;
    } else {
      return 0;
    }
  }

  int index(Key key) {
    var parent = _root.getParent(key);
    if (parent != null) {
      return parent.children.indexWhere((element) => element.key == key);
    } else {
      return 0;
    }
  }

  Map<Key, bool> history() {
    final Map<Key, bool> history = {};
    var current = _root;

    while (current.currentChild != null) {
      current = current.find(current.currentChild!)!;
      history[current.key] = current.userGenerated;
    }

    return history;
  }

  List<Map<String, dynamic>> getMessages() {
    final List<Map<String, dynamic>> messages = [];
    var current = _root;

    while (current.currentChild != null) {
      current = current.find(current.currentChild!)!;
      String role;
      if (current.userGenerated) {
        role = "user";
      } else {
        role = "assistant";
      }
      messages.add({"role": role, "content": current.message});
    }

    if (messages.isNotEmpty) {
      messages.remove(messages.last); //remove last message
    }

    return messages;
  }

  StreamController<String> getMessageStream(Key key) {
    return _root.find(key)?.messageController ??
        StreamController<String>.broadcast();
  }

  StreamController<int> getFinaliseStream(Key key) {
    return _root.find(key)?.finaliseController ??
        StreamController<int>.broadcast();
  }

  /// ------------------- Model Switching -------------------

  void switchLlamaCpp() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastLlamaCpp = json.decode(prefs.getString("llama_cpp_model") ?? "{}");
    Logger.log(lastLlamaCpp.toString());
    
    if (lastLlamaCpp.isNotEmpty) {
      model = LlamaCppModel.fromMap(lastLlamaCpp);
    } 
    else {
      model = LlamaCppModel();
    }

    prefs.setInt("llm_type", model.type.index);
    notifyListeners();
  }

  void switchOpenAI() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastOpenAI = json.decode(prefs.getString("open_ai_model") ?? "{}");
    Logger.log(lastOpenAI.toString());
    
    if (lastOpenAI.isNotEmpty) {
      model = OpenAiModel.fromMap(lastOpenAI);
    } 
    else {
      model = OpenAiModel();
    }

    prefs.setInt("llm_type", model.type.index);
    notifyListeners();
  }

  void switchOllama() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastOllama = json.decode(prefs.getString("ollama_model") ?? "{}");
    Logger.log(lastOllama.toString());
    
    if (lastOllama.isNotEmpty) {
      model = OllamaModel.fromMap(lastOllama);
    } 
    else {
      model = OllamaModel();
      await model.resetUri();
    }

    prefs.setInt("llm_type", model.type.index);
    notifyListeners();
  }

  void switchMistralAI() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastMistralAI = json.decode(prefs.getString("mistral_ai_model") ?? "{}");
    Logger.log(lastMistralAI.toString());
    
    if (lastMistralAI.isNotEmpty) {
      model = MistralAiModel.fromMap(lastMistralAI);
    } 
    else {
      model = MistralAiModel();
    }

    prefs.setInt("llm_type", model.type.index);
    notifyListeners();
  }
}
