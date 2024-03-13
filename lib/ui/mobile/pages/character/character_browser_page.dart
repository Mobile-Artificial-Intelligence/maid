import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/ui/mobile/widgets/appbars/generic_app_bar.dart';
import 'package:maid/ui/mobile/widgets/tiles/character_browser_tile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CharacterBrowserPage extends StatefulWidget {
  const CharacterBrowserPage({super.key});

  @override
  State<CharacterBrowserPage> createState() => _CharacterBrowserPageState();
}

class _CharacterBrowserPageState extends State<CharacterBrowserPage> {
  // Changed from Map to List of Character
  final List<Character> _characters = [];
  Key _current = UniqueKey();

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    final prefs = await SharedPreferences.getInstance();
    final String charactersJson = prefs.getString("characters") ?? '[]';
    final List charactersList = json.decode(charactersJson);

    setState(() {
      _characters.clear();
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
    _characters.removeWhere((character) => character.key == _current);
    final String charactersJson =
        json.encode(_characters.map((character) => character.toMap()).toList());
    await prefs.setString("characters", charactersJson);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Character>(
      builder: (context, character, child) {
        _current = character.key;

        if (!_characters.contains(character)) {
          _characters.insert(0, character);
        }

        return Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              title: const Text("Character Browser"),
              actions: [
                const Expanded(child: SizedBox()),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      final newCharacter = Character();
                      _characters.add(newCharacter);
                      character.from(newCharacter);
                    });
                  },
                ),
              ],
            ),
            body: ListView.builder(
              itemCount: _characters.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(
                      8.0), // Adjust the padding value as needed
                  child: CharacterBrowserTile(
                    character: _characters[index],
                  ),
                );
              },
            ));
      },
    );
  }
}
