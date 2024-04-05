import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:langchain/langchain.dart';
import 'package:maid/classes/chat_node_tree.dart';
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
  ChatNodeTree chat = ChatNodeTree();
  
  String _name = "";

  bool get isBusy => _busy;

  String get name => _name;
  

  Key get key => _key;

  set busy(bool value) {
    _busy = value;
    notifyListeners();
  }

  set name(String name) {
    _name = name;
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

  Session.from(Session session) {
    from(session);
  }

  Session.fromMap(Map<String, dynamic> inputJson) {
    fromMap(inputJson);
  }

  void newSession() {
    name = "New Chat";
    chat = ChatNodeTree();
    model = LlamaCppModel();
    notifyListeners();
  }

  Session copy() {
    return Session.from(this);
  }

  void from(Session session) {
    _key = session.key;
    _name = session.name;
    chat = session.chat;
    model = session.model;
    notifyListeners();
  }

  void fromMap(Map<String, dynamic> inputJson) {
    chat.root = ChatNode.fromMap(inputJson['chat'] ?? {});

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
      'chat': chat.root.toMap(),
      'llm_type': model.type.index,
      'model': model.toMap(),
    };
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

    messages.addAll(chat.getMessages());

    for (var message in messages) {
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
    var parent = chat.parentOf(key);
    if (parent == null) {
      return;
    } 
    parent.currentChild = null;
    chat.add(UniqueKey(), role: ChatRole.assistant);

    if (model.type == AiPlatformType.llamacpp) {
      (model as LlamaCppModel).reset();
    }
    
    prompt(context);
    notifyListeners();
  }

  void edit(Key key, String message, BuildContext context) {
    var parent = chat.parentOf(key);
    if (parent != null) {
      parent.currentChild = null;
    }
    chat.add(UniqueKey(), role: ChatRole.user, message: message);
    chat.add(UniqueKey(), role: ChatRole.assistant);

    if (model.type == AiPlatformType.llamacpp) {
      (model as LlamaCppModel).reset();
    }

    prompt(context);
    notifyListeners();
  }

  void stop() {
    (model as LlamaCppModel).stop();
    _busy = false;
    Logger.log('Local generation stopped');
    finalise();
    notifyListeners();
  }

  void stream(String? message) async {
    if (message == null) {
      finalise();
    } else {
      chat.buffer += message;

      if (!(chat.tail.messageController.isClosed)) {
        chat.tail.messageController.add(chat.buffer);
        chat.buffer = "";
      }

      chat.tail.message += message;
    }
  }

  void finalise() {
    _busy = false;

    chat.tail.messageController.close();

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("last_session", json.encode(toMap()));
    });

    notifyListeners();
  }

  /// -------------------------------------- Model Switching --------------------------------------

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
