import 'package:flutter/material.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/ui/mobile/pages/character_page.dart';
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
            ]),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CharacterPage()));
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            tileColor: Theme.of(context).colorScheme.primary);
      },
    );
  }
}
