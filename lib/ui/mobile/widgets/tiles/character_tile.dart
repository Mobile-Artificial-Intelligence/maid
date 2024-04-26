import 'package:flutter/material.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/providers/user.dart';
import 'package:maid/static/utilities.dart';
import 'package:maid_ui/maid_ui.dart';
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
        );

        if (title.length >= 200) {
          title = "${title.substring(0, 200)}...";
        }

        return Column(children: [
          Text("Character - ${character.name}"),
          const SizedBox(height: 10.0),
          ListTile(
            leading: FutureAvatar(
              key: character.key,
              image: character.profile,
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
