import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/classes/providers/character.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/classes/providers/large_language_models/google_gemini_model.dart';
import 'package:maid/classes/providers/large_language_models/llama_cpp_model.dart';
import 'package:maid/classes/providers/large_language_models/mistral_ai_model.dart';
import 'package:maid/classes/providers/large_language_models/ollama_model.dart';
import 'package:maid/classes/providers/large_language_models/open_ai_model.dart';
import 'package:maid/classes/providers/session.dart';
import 'package:maid/classes/providers/user.dart';
import 'package:maid/classes/static/logger.dart';
import 'package:maid/enumerators/large_language_model_type.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppData extends ChangeNotifier {
  static AppData of(BuildContext context) => Provider.of<AppData>(context, listen: false);

  AppData(this._sessions, this._characters, this._currentSession, this._currentCharacter, this._user, LargeLanguageModelType llmType) {
    _currentSession.addListener(notify);
    _currentCharacter.addListener(notify);

    switch (llmType) {
      case LargeLanguageModelType.llamacpp:
        switchLlamaCpp();
        break;
      case LargeLanguageModelType.openAI:
        switchOpenAI();
        break;
      case LargeLanguageModelType.ollama:
        switchOllama();
        break;
      case LargeLanguageModelType.mistralAI:
        switchMistralAI();
        break;
      case LargeLanguageModelType.gemini:
        switchGemini();
        break;
      default:
        switchLlamaCpp();
        break;
    }
  }

  LargeLanguageModel model = LargeLanguageModel();

  final List<Session> _sessions;
  final List<Character> _characters;
  Session _currentSession;
  Character _currentCharacter;
  
  User _user;

  List<Session> get sessions {
    _sessions.removeWhere((element) => element == _currentSession);

    return List.from([_currentSession, ..._sessions]);
  }

  List<Character> get characters {
    _characters.removeWhere((element) => element.key == _currentCharacter.key);

    return List.from([_currentCharacter, ..._characters]);
  }

  Session get currentSession => _currentSession;

  Character get currentCharacter => _currentCharacter;

  User get user => _user;

  set currentSession(Session session) {
    if (!currentSession.chat.tail.finalised) return;

    _sessions.insert(0, _currentSession);

    _currentSession = session;

    _currentSession.addListener(notify);

    save().then((value) => notifyListeners());
  }

  set currentCharacter(Character character) {
    _characters.insert(0, _currentCharacter);

    _currentCharacter = character;

    _currentCharacter.addListener(notify);

    save().then((value) => notifyListeners());
  }

  set user(User user) {
    _user = user;
    notifyListeners();
  }

  static Future<AppData> get last async {
    final prefs = await SharedPreferences.getInstance();

    String? sessionsString = prefs.getString("sessions");
    String? charactersString = prefs.getString("characters");
    int llmTypeInt = prefs.getInt("llm_type") ?? LargeLanguageModelType.ollama.index;

    List<Session> sessions = [];
    List<Character> characters = [];

    if (sessionsString != null) {
      sessions = (json.decode(sessionsString) as List).map((e) => Session.fromMap(null, e)).toList();
    }

    if (charactersString != null) {
      characters = (json.decode(charactersString) as List).map((e) => Character.fromMap(null, e)).toList();
    }

    final session = await Session.last;
    final character = await Character.last;
    final user = await User.last;
    final llmType = LargeLanguageModelType.values[llmTypeInt];

    return AppData(
      sessions, 
      characters, 
      session, 
      character, 
      user,
      llmType
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    _sessions.removeWhere((element) => element.key == _currentSession.key);
    final sessionsMaps = _sessions.map((e) => e.toMap()).toList();

    _characters.removeWhere((element) => element.key == _currentCharacter.key);
    final characterMaps = _characters.map((e) => e.toMap()).toList();

    final futures = [
      prefs.setString("sessions", json.encode(sessionsMaps)),
      prefs.setString("characters", json.encode(characterMaps)),
      prefs.setInt("llm_type", model.type.index),
      _currentSession.save(),
      _currentCharacter.save(),
      _user.save(),
      model.save()
    ];

    await Future.wait(futures);
  }

  void newSession() {
    int index = 0;

    for (int i = 1; i <= sessions.length; i++) {
      if (!sessions.any((element) => element.name == "New Chat $i")) {
        index = i;
        break;
      }
    }

    currentSession = Session(notify, index);
  }

  void newCharacter() {
    currentCharacter = Character(notify);
  }

  void addCharacter(Character character) {
    final index = _characters.indexWhere((element) => element.key == character.key);

    if (index.isNegative) {
      _characters.insert(0, character);
      notifyListeners();
    }
  }

  void removeSession(Session session) {
    if (session == _currentSession) {
      _currentSession = _sessions.firstOrNull ?? Session(notify, 0);
      notifyListeners();
      return;
    }

    final index = _sessions.indexWhere((element) => element.key == session.key);

    if (!index.isNegative) {
      _sessions.removeAt(index);
      notifyListeners();
    }
  }

  void removeCharacter(Character character) {
    final index = _characters.indexWhere((element) => element.key == character.key);

    if (!index.isNegative) {
      _characters.removeAt(index);
      notifyListeners();
    }
  }

  void clearSessions() {
    _sessions.clear();
    notifyListeners();
  }

  void clearCharacters() {
    _characters.clear();
    notifyListeners();
  }

  void reset() {
    clearSessions();
    clearCharacters();
    _currentCharacter = Character(notify);
    _currentSession = Session(notify, 0);
    _user = User(notify);
    notifyListeners();
  }
  
  void notify() {
    save().then((value) => notifyListeners());
  }

  /// -------------------------------------- Model Switching --------------------------------------

  void switchLlamaCpp() async {
    if (model.type != LargeLanguageModelType.none) {
      model.save();
    }

    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastLlamaCpp = json.decode(prefs.getString("llama_cpp_model") ?? "{}");
    Logger.log(lastLlamaCpp.toString());
    
    if (lastLlamaCpp.isNotEmpty) {
      model = LlamaCppModel.fromMap(notify, lastLlamaCpp);
    } 
    else {
      model = LlamaCppModel(listener: notify);
    }

    prefs.setInt("llm_type", model.type.index);
    notify();
  }

  void switchOpenAI() async {
    if (model.type != LargeLanguageModelType.none) {
      model.save();
    }

    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastOpenAI = json.decode(prefs.getString("open_ai_model") ?? "{}");
    Logger.log(lastOpenAI.toString());
    
    if (lastOpenAI.isNotEmpty) {
      model = OpenAiModel.fromMap(notify, lastOpenAI);
    } 
    else {
      model = OpenAiModel(listener: notify);
    }

    prefs.setInt("llm_type", model.type.index);
    notify();
  }

  void switchOllama() async {
    if (model.type != LargeLanguageModelType.none) {
      model.save();
    }

    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastOllama = json.decode(prefs.getString("ollama_model") ?? "{}");
    Logger.log(lastOllama.toString());
    
    if (lastOllama.isNotEmpty) {
      model = OllamaModel.fromMap(notify, lastOllama);
    } 
    else {
      model = OllamaModel(listener: notify);
      model.resetUri();
    }

    prefs.setInt("llm_type", model.type.index);
    notifyListeners();
  }

  void switchMistralAI() async {
    if (model.type != LargeLanguageModelType.none) {
      model.save();
    }

    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastMistralAI = json.decode(prefs.getString("mistral_ai_model") ?? "{}");
    Logger.log(lastMistralAI.toString());
    
    if (lastMistralAI.isNotEmpty) {
      model = MistralAiModel.fromMap(notify, lastMistralAI);
    } 
    else {
      model = MistralAiModel(listener: notify);
    }

    prefs.setInt("llm_type", model.type.index);
    notify();
  }

  void switchGemini() async {
    if (model.type != LargeLanguageModelType.none) {
      model.save();
    }
    
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastGemini = json.decode(prefs.getString("google_gemini_model") ?? "{}");
    Logger.log(lastGemini.toString());
    
    if (lastGemini.isNotEmpty) {
      model = GoogleGeminiModel.fromMap(notify, lastGemini);
    } 
    else {
      model = GoogleGeminiModel(listener: notify);
    }

    prefs.setInt("llm_type", model.type.index);
    notify();
  }
}
