import 'package:flutter/material.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/providers/user.dart';
import 'package:maid/static/utilities.dart';
import 'package:provider/provider.dart';

class CharacterTile extends StatelessWidget {
  const CharacterTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<User, Character>(
      builder: (context, user, character, child) {
        String title = Utilities.formatPlaceholders(
          character.description, 
          user.name, 
          character.name
        ).substring(0, 100);

        if (title.length >= 200) {
          title += '...';
        }

        return Column(children: [
          Text("Character - ${character.name}"),
          const SizedBox(height: 10.0),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: const AssetImage("assets/maid.png"),
              foregroundImage: Image.file(character.profile).image,
              radius: 25,
            ),
            minLeadingWidth: 60,
            title: Text(
              title, 
              style: const TextStyle(fontSize: 12.0)
            )
          )
        ]);
      },
    );
  }
}
