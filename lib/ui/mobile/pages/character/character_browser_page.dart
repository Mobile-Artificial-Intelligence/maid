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
  final _characters = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      final loadedCharacters =
          json.decode(prefs.getString("characters") ?? "{}");
      _characters.addAll(loadedCharacters);
    });
  }

  @override
  void dispose() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("characters", json.encode(_characters));
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GenericAppBar(title: "Character Browser"),
      body: Consumer<Character>(
        builder: (context, character, child) {
          _characters[character.name] = character.toMap();

          SharedPreferences.getInstance().then((prefs) {
            prefs.setString("last_character", json.encode(character.toMap()));
          });

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _characters.length,
            itemBuilder: (context, index) {
              final character = _characters.values.elementAt(index);
              return CharacterBrowserTile(
                character: Character.fromMap(character),
              );
            },
          );
        },
      ),
    );
  }
}