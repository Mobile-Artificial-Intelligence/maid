import 'dart:convert';
import 'dart:io';

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

  static void save() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.clear();

      _models[model.nameController.text] = model.toMap();
      Logger.log("Model Saved: ${model.nameController.text}");
      _characters[character.nameController.text] = character.toMap();
      Logger.log("Character Saved: ${character.nameController.text}");

      prefs.setString("models", json.encode(_models));
      prefs.setString("characters", json.encode(_characters));
      prefs.setString("current_model", model.nameController.text);
      prefs.setString("current_character", character.nameController.text);

      LocalGeneration.instance.cleanup();
    });
  }

  static void updateModel(String newName) {
    String oldName = model.nameController.text;
    Logger.log("Updating model $oldName ====> $newName");
    model.nameController.text = newName;
    _models.remove(oldName);
    save();
  }

  static void updateCharacter(String newName) {
    String oldName = character.nameController.text;
    Logger.log("Updating character $oldName ====> $newName");
    character.nameController.text = newName;
    _characters.remove(oldName);
    save();
  }

  static void removeModel() {
    _models.remove(model.nameController.text);
    model = Model.fromMap(
      _models[_models.keys.lastOrNull ?? "Default"] ?? {}
    );
    save();
  }

  static void removeCharacter() {
    _characters.remove(character.nameController.text);
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
    Logger.log("Model Set: ${model.nameController.text}");
    save();
  }

  static void setCharacter(String characterName) {
    save();
    character = Character.fromMap(_characters[characterName] ?? {});
    Logger.log("Character Set: ${character.nameController.text}");
    save();
  }

  static bool checkFileExists(String filePath) {
    File file = File(filePath);
    return file.existsSync();
  }
}