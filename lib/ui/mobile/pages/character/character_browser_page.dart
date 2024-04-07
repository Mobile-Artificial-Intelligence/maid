import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/ui/mobile/widgets/session_busy_overlay.dart';
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
  final List<Character> characters = [];
  Key current = UniqueKey();

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
      characters.clear();
      for (var characterMap in charactersList) {
        characters.add(Character.fromMap(characterMap));
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
    characters.removeWhere((character) => character.key == current);
    final String charactersJson =
        json.encode(characters.map((character) => character.toMap()).toList());
    await prefs.setString("characters", charactersJson);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Character>(
      builder: (context, character, child) {
        // If characters contains a character where character.key == current,
        // then insert a copy of character at index 0
        current = character.key;

        var contains = false;

        for (var element in characters) {
          if (element.key == current) {
            contains = true;
            break;
          }
        }

        if (!contains) {
          characters.insert(0, character.copy());
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.background,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            elevation: 0.0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: const Text("Character Browser"),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    final newCharacter = Character();
                    characters.add(newCharacter);
                    character.from(newCharacter);
                  });
                },
              ),
            ],
          ),
          body: SessionBusyOverlay(
              child: ListView.builder(
                itemCount: characters.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(
                        8.0), // Adjust the padding value as needed
                    child: CharacterBrowserTile(
                      character: characters[index],
                      onDelete: () {
                        setState(() {
                          characters.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              )
            )
          );
      },
    );
  }
}
