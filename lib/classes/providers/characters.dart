import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/classes/providers/character.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CharacterCollection extends ChangeNotifier {
  static CharacterCollection of(BuildContext context) => Provider.of<CharacterCollection>(context, listen: false);

  CharacterCollection(this._characters, this._current) {
    _current.addListener(notify);
  }

  final List<Character> _characters;
  Character _current;

  List<Character> get list {
    _characters.removeWhere((element) => element.key == _current.key);

    return List.from([_current, ..._characters]);
  }

  Character get current => _current;

  set current(Character character) {
    _characters.insert(0, _current);

    _current = character;

    _current.addListener(notify);

    save().then((value) => notifyListeners());
  }

  static Future<CharacterCollection> get last async {
    final prefs = await SharedPreferences.getInstance();

    String? charactersString = prefs.getString("characters");

    List<Character> characters = [];

    if (charactersString != null) {
      characters = (json.decode(charactersString) as List).map((e) => Character.fromMap(null, e)).toList();
    }

    final character = await Character.last;

    return CharacterCollection(
      characters, 
      character
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    _characters.removeWhere((element) => element.key == _current.key);
    final characterMaps = _characters.map((e) => e.toMap()).toList();

    final futures = [
      prefs.setString("characters", json.encode(characterMaps)),
      _current.save(),
    ];

    await Future.wait(futures);
  }

  void newCharacter() {
    current = Character(notify);
  }

  void addCharacter(Character character) {
    final index = _characters.indexWhere((element) => element.key == character.key);

    if (index.isNegative) {
      _characters.insert(0, character);
      notifyListeners();
    }
  }

  void removeCharacter(Character character) {
    final index = _characters.indexWhere((element) => element.key == character.key);

    if (!index.isNegative) {
      _characters.removeAt(index);
      notifyListeners();
    }
  }

  void clearCharacters() {
    _characters.clear();
    notifyListeners();
  }

  void reset() {
    clearCharacters();
    _current = Character(notify);
    notifyListeners();
  }
  
  void notify() {
    save().then((value) => notifyListeners());
  }
}
