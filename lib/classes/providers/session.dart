import 'dart:async';
import 'dart:convert';

import 'package:babylon_tts/babylon_tts.dart';
import 'package:flutter/material.dart';
import 'package:maid/classes/chat_node_tree.dart';
import 'package:maid/classes/providers/app_preferences.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/enumerators/chat_role.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:maid/classes/providers/character.dart';
import 'package:maid/classes/providers/user.dart';
import 'package:maid/classes/static/logger.dart';
import 'package:maid/classes/chat_node.dart';
import 'package:maid/classes/static/utilities.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Session extends ChangeNotifier {
  ChatNodeTree chat = ChatNodeTree();
  Key _key = UniqueKey();

  Key get key => _key;
  
  String _name = "";

  String get name => _name;


  set busy(bool value) {
    notifyListeners();
  }

  set name(String name) {
    _name = name;
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }

  static Session of(BuildContext context) => AppData.of(context).currentSession;

  Session(VoidCallback? listener, int index) {
    if (listener != null) {
      addListener(listener);
    }

    newSession(index);
  }

  Session.fromMap(VoidCallback? listener, Map<String, dynamic> inputJson) {
    if (listener != null) {
      addListener(listener);
    }

    fromMap(inputJson);
  }

  static Future<Session> get last async {
    final prefs = await SharedPreferences.getInstance();

    String? lastSessionString = prefs.getString("last_session");

    Map<String, dynamic> lastSession = json.decode(lastSessionString ?? "{}");

    return Session.fromMap(null, lastSession);
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString("last_session", json.encode(toMap()));
  }

  void newSession(int index) {
    _key = UniqueKey();
    _name = "New Chat${index <= 0 ? "" : " $index"}";
    chat = ChatNodeTree();
    notifyListeners();
  }

  void from(Session session) {
    _key = session.key;
    _name = session.name;
    chat = session.chat;
    notifyListeners();
  }

  void fromMap(Map<String, dynamic> inputJson) {
    if (inputJson.isEmpty) {
      newSession(0);
      return;
    }

    _key = UniqueKey();

    _name = inputJson['name'] ?? "New Chat";

    chat.root = ChatNode.fromMap(inputJson['chat'] ?? {});
    
    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'chat': chat.root.toMap()
    };
  }

  void prompt(BuildContext context) async {
    final user = User.of(context);
    final character = Character.of(context);
    final appPreferences = AppPreferences.of(context);
    final model = LargeLanguageModel.of(context);

    final description = Utilities.formatPlaceholders(character.description, user.name, character.name);
    final personality = Utilities.formatPlaceholders(character.personality, user.name, character.name);
    final scenario = Utilities.formatPlaceholders(character.scenario, user.name, character.name);
    final system = Utilities.formatPlaceholders(character.system, user.name, character.name);

    final preprompt = 'Description: $description\nPersonality: $personality\nScenario: $scenario\nSystem: $system';

    List<ChatNode> messages = [];

    messages.add(ChatNode(role: ChatRole.system, content: preprompt));
    messages.addAll(chat.getChat());

    Logger.log("Prompting with ${model.type.name}");

    final streamController = StreamController<String>.broadcast();

    final promptStream = model.prompt(messages);

    streamController.stream.listen((event) {
      chat.tail.content += event;
      notifyListeners();
    });

    if (appPreferences.autoTextToSpeech) {
      Babylon.stringStreamToSpeech(streamController.stream);
    }

    await for (var message in promptStream) {
      streamController.add(message);
    }

    chat.tail.finalised = true;

    if (chat.root.children.isNotEmpty && 
        chat.root.children.first.content.isNotEmpty && 
        _name.contains("New Chat")
    ) {
      _name = chat.root.children.first.content;
    }

    save();
    notifyListeners();
  }

  void regenerate(String hash, BuildContext context) {
    var parent = chat.parentOf(hash);
    if (parent == null) {
      return;
    } 
    parent.currentChild = null;
    chat.add(role: ChatRole.assistant);
    
    prompt(context);
    notifyListeners();
  }

  void edit(String hash, String message, BuildContext context) {
    var parent = chat.parentOf(hash);
    if (parent != null) {
      parent.currentChild = null;
    }
    chat.add(role: ChatRole.user, content: message);
    chat.add(role: ChatRole.assistant);

    prompt(context);
    notifyListeners();
  }
}
