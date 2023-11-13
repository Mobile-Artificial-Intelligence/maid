import 'dart:convert';
import 'dart:io';

import 'package:maid/static/generation_manager.dart';
import 'package:maid/static/host.dart';
import 'package:maid/static/logger.dart';
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

  static void _saveMisc(SharedPreferences prefs) {
    prefs.remove("remote");

    prefs.setBool("remote", GenerationManager.remote);
    prefs.setString("remote_url", Host.url);
  }

  static void _saveModels(SharedPreferences prefs) {
    prefs.remove("models");
    prefs.remove("current_model");

    _models[model.preset] = model.toMap();
    Logger.log("Model Saved: ${model.preset}");

    prefs.setString("models", json.encode(_models));
    prefs.setString("current_model", model.preset);
  }

  static void _saveCharacters(SharedPreferences prefs) {
    prefs.remove("characters");
    prefs.remove("current_character");
    
    _characters[character.name] = character.toMap();
    Logger.log("Character Saved: ${character.name}");

    prefs.setString("characters", json.encode(_characters));
    prefs.setString("current_character", character.name);
  }

  static void saveModels() {
    SharedPreferences.getInstance().then((prefs) {
      _saveModels(prefs);
    });
    GenerationManager.cleanup();
  }

  static void saveCharacters() {
    SharedPreferences.getInstance().then((prefs) {
      _saveCharacters(prefs);
    });
    GenerationManager.cleanup();
  }

  static Future<void> saveAll() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.clear();
    _saveMisc(prefs);
    _saveModels(prefs);
    _saveCharacters(prefs);
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