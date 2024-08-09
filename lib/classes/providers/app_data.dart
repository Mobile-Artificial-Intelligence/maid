import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/classes/providers/character.dart';
import 'package:maid/classes/providers/session.dart';
import 'package:maid/classes/providers/user.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppData extends ChangeNotifier {
  static AppData of(BuildContext context) => Provider.of<AppData>(context, listen: false);

  AppData(this._sessions, this._characters, this._currentSession, this._currentCharacter, this._user) {
    _currentSession.addListener(notify);
    _currentCharacter.addListener(notify);
  }

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

    return AppData(
      sessions, 
      characters, 
      session, 
      character, 
      user
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
      _currentSession.save(),
      _currentCharacter.save(),
      _user.save()
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
}
