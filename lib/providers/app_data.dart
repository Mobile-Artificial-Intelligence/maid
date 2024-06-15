import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/providers/session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppData extends ChangeNotifier {
  final List<Session> _sessions;
  final List<Character> _characters;
  late Session _currentSession;
  late Character _currentCharacter;

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

  int get nextSessionIndex {
    int index = 0;

    for (int i = 1; i <= sessions.length; i++) {
      if (!sessions.any((element) => element.name == "New Chat $i")) {
        index = i;
        break;
      }
    }

    return index;
  }

  set currentSession(Session session) {
    _currentSession = session.copy();
    save().then((value) => notifyListeners());
  }

  set currentCharacter(Character character) {
    _currentCharacter = character.copy();
    save().then((value) => notifyListeners());
  }

  static Future<AppData> get last async {
    final prefs = await SharedPreferences.getInstance();

    String? sessionsString = prefs.getString("sessions");
    String? charactersString = prefs.getString("characters");

    List<Session> sessions = [];
    List<Character> characters = [];

    if (sessionsString != null) {
      sessions = (json.decode(sessionsString) as List).map((e) => Session.fromMap(e)).toList();
    }

    if (charactersString != null) {
      characters = (json.decode(charactersString) as List).map((e) => Character.fromMap(e)).toList();
    }

    if (sessions.isEmpty) {
      sessions.add(Session(0));
    }

    if (characters.isEmpty) {
      characters.add(Character());
    }

    return AppData(sessions, characters);
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    _sessions.removeWhere((element) => element.key == _currentSession.key);
    final sessionsMaps = _sessions.map((e) => e.toMap()).toList();

    _characters.removeWhere((element) => element.key == _currentCharacter.key);
    final characterMaps = _characters.map((e) => e.toMap()).toList();

    final futures = [
      prefs.setString("sessions", json.encode(sessionsMaps)),
      prefs.setString("characters", json.encode(characterMaps))
    ];

    await Future.wait(futures);
  }

  void addSession(Session session) {
    final index = _sessions.indexWhere((element) => element.key == session.key);

    if (index.isNegative) {
      _sessions.insert(0, session);
      notifyListeners();
    }
  }

  void addCharacter(Character character) {
    final index = _characters.indexWhere((element) => element.key == character.key);

    if (index.isNegative) {
      _characters.insert(0, character);
      notifyListeners();
    }
  }

  void removeSession(Session session) {
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

  void setCurrentSession(Session oldCurrentSession, Session newCurrentSession) {
    if (oldCurrentSession.key == newCurrentSession.key) {
      return;
    }

    removeSession(newCurrentSession);
    addSession(oldCurrentSession.copy());
    _currentSession = newCurrentSession;
    save().then((value) => notifyListeners());
  }

  void setCurrentCharacter(Character oldCurrentCharacter, Character newCurrentCharacter) {
    if (oldCurrentCharacter.key == newCurrentCharacter.key) {
      return;
    }

    removeCharacter(newCurrentCharacter);
    addCharacter(oldCurrentCharacter.copy());
    _currentCharacter = newCurrentCharacter;
    save().then((value) => notifyListeners());
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
  }

  AppData(this._sessions, this._characters);
}
