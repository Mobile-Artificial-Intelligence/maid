import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/static/generation_manager.dart';
import 'package:maid/static/host.dart';
import 'package:maid/static/logger.dart';
import 'package:maid/static/message_manager.dart';
import 'package:maid/types/chat_node.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemoryManager {
  static Map<String, dynamic> _sessions = {};

  static void init() {
    SharedPreferences.getInstance().then((prefs) {
      GenerationManager.remote = prefs.getBool("remote") ?? false;
      Host.url = prefs.getString("remote_url") ?? Host.url;

      _sessions = json.decode(prefs.getString("sessions") ?? "{}");

      if (_sessions.isNotEmpty) {
        MessageManager.fromMap(
            _sessions[prefs.getString("last_session") ?? "Session"] ?? {});
      }
    });
  }

  static void saveMisc() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool("remote", GenerationManager.remote);
      Logger.log("Remote Flag Saved: ${GenerationManager.remote}");

      prefs.setString("remote_url", Host.url);
      Logger.log("Remote URL Saved: ${Host.url}");
    });
    GenerationManager.cleanup();
  }

  static void saveSessions() {
    SharedPreferences.getInstance().then((prefs) {
      String key = MessageManager.root.message;
      if (key.isEmpty) key = "Session";

      _sessions[key] = MessageManager.root.toMap();
      Logger.log("Session Saved: $key");

      prefs.setString("sessions", json.encode(_sessions));
      prefs.setString("last_session", key);
    });
    GenerationManager.cleanup();
  }

  static Future<void> saveAll() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.clear();
    saveMisc();
    saveSessions();
    GenerationManager.cleanup();
  }

  static void updateSession(String newName) {
    String oldName = MessageManager.root.message;
    Logger.log("Updating session $oldName ====> $newName");
    MessageManager.root.message = newName;
    _sessions.remove(oldName);
    saveSessions();
  }

  static void removeSession(String sessionName) {
    _sessions.remove(sessionName);
    String? key = _sessions.keys.lastOrNull;
    
    if (key == null) {
      MessageManager.root = ChatNode(key: UniqueKey());
    } else {
      MessageManager.fromMap(_sessions[key]!);
    }
    
    saveSessions();
  }

  static List<String> getSessions() {
    return _sessions.keys.toList();
  }

  static void setSession(String sessionName) {
    saveSessions();

    if (_sessions.keys.contains(sessionName)) {
      MessageManager.fromMap(_sessions[sessionName] ?? {});
    } else {
      MessageManager.root = ChatNode(key: UniqueKey());
      MessageManager.root.message = sessionName;
    }

    Logger.log("Session Set: ${MessageManager.root.message}");
    saveSessions();
  }
}