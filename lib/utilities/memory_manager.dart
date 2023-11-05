import 'dart:convert';

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
    var prefs = await SharedPreferences.getInstance();
    
    _models = json.decode(prefs.getString("models") ?? "{}");
    _characters = json.decode(prefs.getString("characters") ?? "{}");

    if (_models.isEmpty) {
      model = Model();
    } else {
      model = Model.fromMap(_models[prefs.getString("current_model") ?? "Default"] ?? {});
    }

    if (_characters.isEmpty) {
      character = Character();
    } else {
      character = Character.fromMap(_characters[prefs.getString("current_character") ?? "Default"] ?? {});
    }
  }

  Future<void> save() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.clear();
    
    _models[model.name] = model.toMap();
    Logger.log("Model Saved: ${model.name}");
    _characters[character.name] = character.toMap();
    Logger.log("Character Saved: ${character.name}");

    prefs.setString("models", json.encode(_models));
    prefs.setString("characters", json.encode(_characters));
    prefs.setString("current_model", model.name);
    prefs.setString("current_character", character.name);

    Core.instance.cleanup();
  }

  Future<void> updateModel(String newName) async {
    String oldName = model.name;
    model.name = newName;
    _models.remove(oldName);
    await save();
  }

  Future<void> updateCharacter(String newName) async {
    String oldName = character.name;
    character.name = newName;
    _characters.remove(oldName);
    await save();
  }

  Future<void> removeModel() async {
    _models.remove(model.name);
    model = Model.fromMap(_models[_models.keys.lastOrNull ?? "Default"] ?? {});
    await save();
  }

  Future<void> removeCharacter() async {
    _characters.remove(character.name);
    character = Character.fromMap(_characters[_characters.keys.lastOrNull ?? "Default"] ?? {});
    await save();
  }

  List<String> getModels() {
    return _models.keys.toList();
  }

  List<String> getCharacters() {
    return _characters.keys.toList();
  }

  Future<void> setModel(String? modelName) async {
    await save();
    model = Model.fromMap(_models[modelName ?? "Default"] ?? {});
  }

  Future<void> setCharacter(String? characterName) async {
    await save();
    character = Character.fromMap(_characters[characterName ?? "Default"] ?? {});
  }
}