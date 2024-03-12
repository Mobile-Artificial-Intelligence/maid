import 'package:flutter/material.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/providers/user.dart';
import 'package:maid/static/utilities.dart';
import 'package:provider/provider.dart';

class CharacterBrowserTile extends StatelessWidget {
  final Character character;

  const CharacterBrowserTile({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Consumer<User>(
      builder: (context, user, child) {
        return ListTile(
          tileColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          //Square image of the character
          leading: CircleAvatar(
            backgroundImage: const AssetImage("assets/maid.png"),
            foregroundImage: Image.file(character.profile).image,
            radius: 25,
          ),
          minLeadingWidth: 60,
          title: Column(children: [
            Text(character.name),
            const SizedBox(height: 10.0),
            Text(
              Utilities.formatPlaceholders(
                character.description, 
                user.name, 
                character.name
              ), 
              style: const TextStyle(fontSize: 12.0)
            ),
          ])
        );
      },
    );
  }
}

