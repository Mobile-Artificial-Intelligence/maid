import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:maid/config/model.dart';
import 'package:maid/config/character.dart';

Settings settings = Settings();

class Settings { 
  Map<String, dynamic> _models = {};
  Map<String, dynamic> _characters = {};
  
  static String _logString = "";

  static String get getLog => _logString;

  static void log(String message) {
    _logString += "$message\n";
  }

  Future<void> init() async {
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
    
    _models[model.getName()] = model.toMap();
    _characters[character.getName()] = character.toMap();

    prefs.setString("models", json.encode(_models));
    prefs.setString("characters", json.encode(_characters));
    prefs.setString("current_model", model.getName());
    prefs.setString("current_character", character.getName());
  }

  List<String> getModels() {
    return _models.keys.toList();
  }

  List<String> getCharacters() {
    return _characters.keys.toList();
  }

  void updateModel(String newName) {
    String oldName = model.getName();
    model.parameters["name"] = newName;
    _models.remove(oldName);
    save();
  }

  Future<void> setModel(String? modelName) async {
    await settings.save();
    model = Model.fromMap(_models[modelName ?? "Default"] ?? {});
  }

  Future<void> setCharacter(String? characterName) async {
    await settings.save();
    character = Character.fromMap(_characters[characterName ?? "Default"] ?? {});
  }
}