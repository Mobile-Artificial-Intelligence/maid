import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/ui/mobile/widgets/appbars/generic_app_bar.dart';
import 'package:maid/ui/mobile/widgets/tiles/character_browser_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CharacterBrowserPage extends StatefulWidget {
  const CharacterBrowserPage({super.key});

  @override
  State<CharacterBrowserPage> createState() => _CharacterBrowserPageState();
}

class _CharacterBrowserPageState extends State<CharacterBrowserPage> {
  // Changed from Map to List of Character
  final List<Character> _characters = [];

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    final prefs = await SharedPreferences.getInstance();
    final String charactersJson = prefs.getString("characters") ?? '[]';
    final List charactersList = json.decode(charactersJson);

    final String lastCharacterJson = prefs.getString("last_character") ?? '{}';
    final Map<String, dynamic> lastCharacterMap = json.decode(lastCharacterJson);

    setState(() {
      _characters.clear();
      _characters.add(Character.fromMap(lastCharacterMap));
      for (var characterMap in charactersList) {
        _characters.add(Character.fromMap(characterMap));
      }
    });
  }

  @override
  void dispose() {
    _saveCharacters();
    super.dispose();
  }

  Future<void> _saveCharacters() async {
    final prefs = await SharedPreferences.getInstance();
    final String charactersJson = json.encode(_characters.map((character) => character.toMap()).toList());
    await prefs.setString("characters", charactersJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GenericAppBar(title: "Character Browser"),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _characters.length,
        itemBuilder: (context, index) {
          final character = _characters[index];
          return CharacterBrowserTile(character: character);
        },
      ),
    );
  }
}
