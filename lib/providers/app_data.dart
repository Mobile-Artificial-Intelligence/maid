import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/providers/session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppData extends ChangeNotifier {
  final List<Session> _sessions;
  final List<Character> _characters;

  List<Session> get sessions => _sessions;

  List<Character> get characters => _characters;

  Session get currentSession => _sessions.first;

  Character get currentCharacter => _characters.first;

  set currentSession(Session session) {
    final index = _sessions.indexWhere((element) => element.key == session.key);

    if (index == 0) return;
    
    if (!index.isNegative) {
      _sessions.removeAt(index);
    }
    
    _sessions.insert(0, session);
  }

  set currentCharacter(Character character) {
    final index = _characters.indexWhere((element) => element.key == character.key);

    if (index == 0) return;

    if (!index.isNegative) {
      _characters.removeAt(index);
    }

    _characters.insert(0, character);
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
      sessions.add(Session());
    }

    if (characters.isEmpty) {
      characters.add(Character());
    }

    return AppData(sessions, characters);
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    final sessionsMaps = _sessions.map((e) => e.toMap()).toList();

    final characterMaps = _characters.map((e) => e.toMap()).toList();

    final futures = [
      prefs.setString("sessions", json.encode(sessionsMaps)),
      prefs.setString("characters", json.encode(characterMaps))
    ];

    await Future.wait(futures);
  }

  void setCurrentSession(Session session) {
    currentSession = session;

    notifyListeners();
  }

  void setCurrentCharacter(Character character) {
    currentCharacter = character;

    notifyListeners();
  }

  void addSession(Session session) {
    final index = _sessions.indexWhere((element) => element.key == session.key);

    if (index.isNegative) {
      _sessions.add(session);

      notifyListeners();
    }
  }

  void addCharacter(Character character) {
    final index = _characters.indexWhere((element) => element.key == character.key);

    if (index.isNegative) {
      _characters.add(character);

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

  void updateSession(Session session) {
    final index = _sessions.indexWhere((element) => element.key == session.key);

    if (!index.isNegative) {
      _sessions[index] = session;

      notifyListeners();
    }
  }

  void updateCharacter(Character character) {
    final index = _characters.indexWhere((element) => element.key == character.key);

    if (!index.isNegative) {
      _characters[index] = character;

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
  }

  AppData(this._sessions, this._characters);
}