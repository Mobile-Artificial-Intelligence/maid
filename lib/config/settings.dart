import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:maid/config/model.dart';
import 'package:maid/config/character.dart';

Settings settings = Settings();

class Settings { 
  Map<String, Model> _models = {};
  Map<String, Character> _characters = {};
  String _currentModel = "default";
  String _currentCharacter = "default";
  
  static String _logString = "";

  static String get getLog => _logString;

  Settings() {
    init();
  }

  static void log(String message) {
    _logString += "$message\n";
  }

  void init() async {
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

    _currentModel = prefs.getString("current_model") ?? "default";
    _currentCharacter = prefs.getString("current_character") ?? "default";
  }

  void save() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString("models", json.encode(_models.map((key, value) => MapEntry(key, value.parameters))));
    prefs.setString("characters", json.encode(_characters.map((key, value) => MapEntry(key, value.toMap()))));
    prefs.setString("current_model", _currentModel);
    prefs.setString("current_character", _currentCharacter);
  }

  Model getCurrentModel() {
    if (_models[_currentModel] == null) {
      _models[_currentModel] = Model();
    }
    
    return _models[_currentModel]!;
  }

  Character getCurrentCharacter() {
    if (_characters[_currentCharacter] == null) {
      _characters[_currentCharacter] = Character();
    }
    
    return _characters[_currentCharacter]!;
  }
}