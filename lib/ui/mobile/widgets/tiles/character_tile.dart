import 'package:flutter/material.dart';
import 'package:maid/providers/character.dart';
import 'package:provider/provider.dart';

class CharacterTile extends StatelessWidget {
  const CharacterTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Character>(
      builder: (context, character, child) {
        return ListTile(
            title: Column(children: [
          CircleAvatar(
            backgroundImage: const AssetImage("assets/maid.png"),
            foregroundImage: Image.file(character.profile).image,
            radius: 30,
          ),
          const SizedBox(height: 10.0),
          Text(character.name, textAlign: TextAlign.center),
        ]));
      },
    );
  }
}
