import 'dart:convert';
import 'dart:io';

import 'package:maid/utilities/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:maid/core/core.dart';
import 'package:maid/utilities/model.dart';
import 'package:maid/utilities/character.dart';

MemoryManager memoryManager = MemoryManager();

class MemoryManager {
  Map<String, dynamic> _models = {};
  Map<String, dynamic> _characters = {};

  MemoryManager() {
    init();
  }

  void init() async {
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

  void save() {
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

      Core.instance.cleanup();
    });
  }

  void updateModel(String newName) {
    String oldName = model.nameController.text;
    Logger.log("Updating model $oldName ====> $newName");
    model.nameController.text = newName;
    _models.remove(oldName);
    save();
  }

  void updateCharacter(String newName) {
    String oldName = character.nameController.text;
    Logger.log("Updating character $oldName ====> $newName");
    character.nameController.text = newName;
    _characters.remove(oldName);
    save();
  }

  void removeModel() {
    _models.remove(model.nameController.text);
    model = Model.fromMap(
      _models[_models.keys.lastOrNull ?? "Default"] ?? {}
    );
    save();
  }

  void removeCharacter() {
    _characters.remove(character.nameController.text);
    character = Character.fromMap(
      _characters[_characters.keys.lastOrNull ?? "Default"] ?? {}
    );
    save();
  }

  List<String> getModels() {
    return _models.keys.toList();
  }

  List<String> getCharacters() {
    return _characters.keys.toList();
  }

  void setModel(String modelName) {
    save();
    model = Model.fromMap(_models[modelName] ?? {});
    Logger.log("Model Set: ${model.nameController.text}");
    save();
  }

  void setCharacter(String characterName) {
    save();
    character = Character.fromMap(_characters[characterName] ?? {});
    Logger.log("Character Set: ${character.nameController.text}");
    save();
  }

  bool checkFileExists(String filePath) {
    File file = File(filePath);
    return file.existsSync();
  }
}