import 'dart:convert';
import 'dart:io';

import 'package:maid/static/generation_manager.dart';
import 'package:maid/static/host.dart';
import 'package:maid/static/logger.dart';
import 'package:maid/static/message_manager.dart';
import 'package:maid/types/chat_node.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:maid/types/model.dart';
import 'package:maid/types/character.dart';

class MemoryManager {
  static Map<String, dynamic> _models = {};
  static Map<String, dynamic> _characters = {};

  static void init() {
    SharedPreferences.getInstance().then((prefs) {
      GenerationManager.remote = prefs.getBool("remote") ?? false;
      Host.url = prefs.getString("remote_url") ?? Host.url;

      _models = json.decode(prefs.getString("models") ?? "{}");
      _characters = json.decode(prefs.getString("characters") ?? "{}");
      MessageManager.root = ChatNode.fromMap(
          json.decode(prefs.getString("root") ?? "{}") ?? {});

      if (_models.isEmpty) {
        model = Model();
      } else {
        model = Model.fromMap(
            _models[prefs.getString("current_model") ?? "Default"] ?? {});
      }

      if (_characters.isEmpty) {
        character = Character();
      } else {
        character = Character.fromMap(
            _characters[prefs.getString("current_character") ?? "Default"] ?? {});
      }
    });
  }

  static void saveMisc() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool("remote", GenerationManager.remote);
      Logger.log("Remote Flag Saved: ${GenerationManager.remote}");

      prefs.setString("remote_url", Host.url);
      Logger.log("Remote URL Saved: ${Host.url}");

      prefs.setString("root", json.encode(MessageManager.root.toMap()));
      Logger.log("Message Tree Saved: ${MessageManager.root.toMap()}");
    });
    GenerationManager.cleanup();
  }

  static void saveModels() {
    SharedPreferences.getInstance().then((prefs) {
      _models[model.preset] = model.toMap();
      Logger.log("Model Saved: ${model.preset}");

      prefs.setString("models", json.encode(_models));
      prefs.setString("current_model", model.preset);
    });
    GenerationManager.cleanup();
  }

  static void saveCharacters() {
    SharedPreferences.getInstance().then((prefs) {
      _characters[character.name] = character.toMap();
      Logger.log("Character Saved: ${character.name}");

      prefs.setString("characters", json.encode(_characters));
      prefs.setString("current_character", character.name);
    });
    GenerationManager.cleanup();
  }

  static Future<void> saveAll() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.clear();
    saveMisc();
    saveModels();
    saveCharacters();
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

  static List<String> getModels() {
    return _models.keys.toList();
  }

  static List<String> getCharacters() {
    return _characters.keys.toList();
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

  static bool checkFileExists(String filePath) {
    File file = File(filePath);
    return file.existsSync();
  }
}