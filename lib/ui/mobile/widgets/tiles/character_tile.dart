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
            leading: CircleAvatar(
              backgroundImage: const AssetImage("assets/maid.png"),
              foregroundImage: Image.file(character.profile).image,
              radius: 25,
            ),
            minLeadingWidth: 60,
            title: Column(children: [
              Text(character.name),
              const SizedBox(height: 10.0),
              Text(character.description, style: const TextStyle(fontSize: 12.0)),
            ])
        );
      },
    );
  }
}
