import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:maid/config/model.dart';
import 'package:maid/config/character.dart';

Settings settings = Settings();

class Settings { 
  Map<String, Model> _models = {};
  Map<String, Character> _characters = {};
  
  static String _logString = "";

  static String get getLog => _logString;

  static void log(String message) {
    _logString += "$message\n";
  }

  Future<void> init() async {
    var prefs = await SharedPreferences.getInstance();
    
    var modelsJson = json.decode(prefs.getString("models") ?? "{}");
    var charactersJson = json.decode(prefs.getString("characters") ?? "{}");

    _models = modelsJson.map<String, Model>(
      (String key, dynamic value) => MapEntry<String, Model>(
        key, 
        Model.fromMap(value)
      )
    );

    _characters = charactersJson.map<String, Character>(
      (String key, dynamic value) => MapEntry<String, Character>(
        key, 
        Character.fromMap(value)
      )
    );

    if (_models.isEmpty) {
      _models["default"] = Model();
    }

    if (_characters.isEmpty) {
      _characters["default"] = Character();
    }

    model = _models[prefs.getString("current_model") ?? "default"] ?? Model();
    character = _characters[prefs.getString("current_character") ?? "default"] ?? Character();
  }

  void save() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.clear();

    _models[model.getName()] = model;
    _characters[character.getName()] = character;

    prefs.setString("models", json.encode(_models.map((key, value) => MapEntry(key, value.toMap()))));
    prefs.setString("characters", json.encode(_characters.map((key, value) => MapEntry(key, value.toMap()))));
    prefs.setString("current_model", model.getName());
    prefs.setString("current_character", character.getName());
  }

  List<String> getModels() {
    return _models.keys.toList();
  }

  List<String> getCharacters() {
    return _characters.keys.toList();
  }

  void setModel(String modelName) {
    model = _models[modelName] ?? Model();
  }

  void setCharacter(String characterName) {
    character = _characters[characterName] ?? Character();
  }
}