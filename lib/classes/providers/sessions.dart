import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/classes/providers/session.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Sessions extends ChangeNotifier {
  static Sessions of(BuildContext context) => Provider.of<Sessions>(context, listen: false);

  Sessions(this._sessions, this._current) {
    _current.addListener(notify);
  }

  final List<Session> _sessions;
  Session _current;

  List<Session> get list {
    _sessions.removeWhere((element) => element == _current);

    return List.from([_current, ..._sessions]);
  }

  Session get current => _current;

  set current(Session session) {
    if (!current.chat.tail.finalised) return;

    _sessions.insert(0, _current);

    _current = session;

    _current.addListener(notify);

    save().then((value) => notifyListeners());
  }

  static Future<Sessions> get last async {
    final prefs = await SharedPreferences.getInstance();

    String? sessionsString = prefs.getString("sessions");

    List<Session> sessions = [];

    if (sessionsString != null) {
      sessions = (json.decode(sessionsString) as List).map((e) => Session.fromMap(null, e)).toList();
    }

    final session = await Session.last;

    return Sessions(
      sessions,
      session
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    _sessions.removeWhere((element) => element.key == _current.key);
    final sessionsMaps = _sessions.map((e) => e.toMap()).toList();

    final futures = [
      prefs.setString("sessions", json.encode(sessionsMaps)),
      _current.save(),
    ];

    await Future.wait(futures);
  }

  void newSession() {
    int index = 0;

    for (int i = 1; i <= list.length; i++) {
      if (!list.any((element) => element.name == "New Chat $i")) {
        index = i;
        break;
      }
    }

    current = Session(notify, index);
  }

  void removeSession(Session session) {
    if (session == _current) {
      _current = _sessions.firstOrNull ?? Session(notify, 0);
      notifyListeners();
      return;
    }

    final index = _sessions.indexWhere((element) => element.key == session.key);

    if (!index.isNegative) {
      _sessions.removeAt(index);
      notifyListeners();
    }
  }

  void clearSessions() {
    _sessions.clear();
    notifyListeners();
  }

  void reset() {
    clearSessions();
    _current = Session(notify, 0);
    notifyListeners();
  }
  
  void notify() {
    save().then((value) => notifyListeners());
  }
}
