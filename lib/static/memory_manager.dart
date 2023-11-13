import 'dart:convert';

import 'package:maid/static/generation_manager.dart';
import 'package:maid/static/host.dart';
import 'package:maid/static/logger.dart';
import 'package:maid/static/message_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:maid/types/model.dart';
import 'package:maid/types/character.dart';

class MemoryManager {
  static Map<String, dynamic> _models = {};
  static Map<String, dynamic> _characters = {};
  static Map<String, dynamic> _sessions = {};

  static void init() {
    SharedPreferences.getInstance().then((prefs) {
      GenerationManager.remote = prefs.getBool("remote") ?? false;
      Host.url = prefs.getString("remote_url") ?? Host.url;

      _models = json.decode(prefs.getString("models") ?? "{}");
      _characters = json.decode(prefs.getString("characters") ?? "{}");
      _sessions = json.decode(prefs.getString("sessions") ?? "{}");

      if (_models.isEmpty) {
        model = Model();
      } else {
        model = Model.fromMap(
            _models[prefs.getString("last_model") ?? "Default"] ?? {});
      }

      if (_characters.isEmpty) {
        character = Character();
      } else {
        character = Character.fromMap(
            _characters[prefs.getString("last_character") ?? "Default"] ?? {});
      }

      if (_sessions.isNotEmpty) {
        MessageManager.fromMap(
            _sessions[prefs.getString("last_session") ?? "New Session"] ?? {});
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

  static void saveModels() {
    SharedPreferences.getInstance().then((prefs) {
      _models[model.preset] = model.toMap();
      Logger.log("Model Saved: ${model.preset}");

      prefs.setString("models", json.encode(_models));
      prefs.setString("last_model", model.preset);
    });
    GenerationManager.cleanup();
  }

  static void saveCharacters() {
    SharedPreferences.getInstance().then((prefs) {
      _characters[character.name] = character.toMap();
      Logger.log("Character Saved: ${character.name}");

      prefs.setString("characters", json.encode(_characters));
      prefs.setString("last_character", character.name);
    });
    GenerationManager.cleanup();
  }

  static void saveSessions() {
    SharedPreferences.getInstance().then((prefs) {
      String key = MessageManager.root.message;
      if (key.isEmpty) key = "New Session";

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
    saveModels();
    saveCharacters();
    saveSessions();
    GenerationManager.cleanup();
  }

  static void updateModel(String newName) {
    String oldName = model.preset;
    Logger.log("Updating model $oldName ====> $newName");
    model.preset = newName;
    _models.remove(oldName);
    saveModels();
  }

  static void updateCharacter(String newName) {
    String oldName = character.name;
    Logger.log("Updating character $oldName ====> $newName");
    character.name = newName;
    _characters.remove(oldName);
    saveCharacters();
  }

  static void updateSession(String newName) {
    String oldName = MessageManager.root.message;
    Logger.log("Updating session $oldName ====> $newName");
    MessageManager.root.message = newName;
    _sessions.remove(oldName);
    saveSessions();
  }

  static void removeModel(String modelName) {
    _models.remove(modelName);
    model = Model.fromMap(
      _models[_models.keys.lastOrNull ?? "Default"] ?? {}
    );
    saveModels();
  }

  static void removeCharacter(String characterName) {
    _characters.remove(characterName);
    character = Character.fromMap(
      _characters[_characters.keys.lastOrNull ?? "Default"] ?? {}
    );
    saveCharacters();
  }

  static void removeSession(String sessionName) {
    _sessions.remove(sessionName);
    MessageManager.fromMap(
      _sessions[_sessions.keys.lastOrNull ?? "New Session"] ?? {}
    );
    saveSessions();
  }

  static List<String> getModels() {
    return _models.keys.toList();
  }

  static List<String> getCharacters() {
    return _characters.keys.toList();
  }

  static List<String> getSessions() {
    return _sessions.keys.toList();
  }

  static void setModel(String modelName) {
    saveModels();
    model = Model.fromMap(_models[modelName] ?? {});
    Logger.log("Model Set: ${model.preset}");
    saveModels();
  }

  static void setCharacter(String characterName) {
    saveCharacters();
    character = Character.fromMap(_characters[characterName] ?? {});
    Logger.log("Character Set: ${character.name}");
    saveCharacters();
  }

  static void setSession(String sessionName) {
    saveSessions();
    MessageManager.fromMap(_sessions[sessionName] ?? {});
    Logger.log("Session Set: ${MessageManager.root.message}");
    saveSessions();
  }
}