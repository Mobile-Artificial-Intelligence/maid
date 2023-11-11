import 'dart:convert';
import 'dart:io';

import 'package:maid/utilities/generation_manager.dart';
import 'package:maid/utilities/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:maid/core/local_generation.dart';
import 'package:maid/utilities/model.dart';
import 'package:maid/utilities/character.dart';

class MemoryManager {
  static Map<String, dynamic> _models = {};
  static Map<String, dynamic> _characters = {};

  static void init() {
    SharedPreferences.getInstance().then((prefs) {
      GenerationManager.hosted = prefs.getBool("hosted") ?? false;

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

  static void _save(SharedPreferences prefs) {
    prefs.clear();

    prefs.setBool("hosted", GenerationManager.hosted);

    _models[model.name] = model.toMap();
    Logger.log("Model Saved: ${model.name}");
    _characters[character.name] = character.toMap();
    Logger.log("Character Saved: ${character.name}");

    prefs.setString("models", json.encode(_models));
    prefs.setString("characters", json.encode(_characters));
    prefs.setString("current_model", model.name);
    prefs.setString("current_character", character.name);

    LocalGeneration.instance.cleanup();
  }

  static void save() {
    SharedPreferences.getInstance().then((prefs) {
      _save(prefs);
    });
  }

  static Future<void> asave() async {
    var prefs = await SharedPreferences.getInstance();
    _save(prefs);
  }

  static void updateModel(String newName) {
    String oldName = model.name;
    Logger.log("Updating model $oldName ====> $newName");
    model.name = newName;
    _models.remove(oldName);
    save();
  }

  static void updateCharacter(String newName) {
    String oldName = character.name;
    Logger.log("Updating character $oldName ====> $newName");
    character.name = newName;
    _characters.remove(oldName);
    save();
  }

  static void removeModel(String modelName) {
    _models.remove(modelName);
    model = Model.fromMap(
      _models[_models.keys.lastOrNull ?? "Default"] ?? {}
    );
    save();
  }

  static void removeCharacter(String characterName) {
    _characters.remove(characterName);
    character = Character.fromMap(
      _characters[_characters.keys.lastOrNull ?? "Default"] ?? {}
    );
    save();
  }

  static List<String> getModels() {
    return _models.keys.toList();
  }

  static List<String> getCharacters() {
    return _characters.keys.toList();
  }

  static void setModel(String modelName) {
    save();
    model = Model.fromMap(_models[modelName] ?? {});
    Logger.log("Model Set: ${model.name}");
    save();
  }

  static void setCharacter(String characterName) {
    save();
    character = Character.fromMap(_characters[characterName] ?? {});
    Logger.log("Character Set: ${character.name}");
    save();
  }

  static bool checkFileExists(String filePath) {
    File file = File(filePath);
    return file.existsSync();
  }
}