import 'package:flutter/material.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/providers/user.dart';
import 'package:maid/static/utilities.dart';
import 'package:provider/provider.dart';

class CharacterBrowserTile extends StatefulWidget {
  final Character character;

  const CharacterBrowserTile({super.key, required this.character});

  @override
  State<CharacterBrowserTile> createState() => _CharacterBrowserTileState();
}

class _CharacterBrowserTileState extends State<CharacterBrowserTile> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    return Consumer2<Character, User>(
      builder: (context, character, user, child) {
        selected = character.key == widget.character.key;

        return ListTile(
          tileColor: Theme.of(context).colorScheme.primary,
          selectedTileColor: Theme.of(context).colorScheme.secondary.withOpacity(0.25),
          textColor: Colors.white,
          selectedColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          // Square image with rounded corners of the character
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10.0), // Adjust the corner radius here
            child: Image(
              image: Image.file(widget.character.profile).image,
              width: 50, // Adjust the size as needed
              height: 50,
              fit: BoxFit.cover, // This ensures the image covers the square area
            ),
          ),
          minLeadingWidth: 60,
          title: Column(children: [
            Text(widget.character.name),
            const SizedBox(height: 10.0),
            Text(
              Utilities.formatPlaceholders(widget.character.description, user.name, widget.character.name),
              style: const TextStyle(fontSize: 12.0),
            ),
          ]),
          selected: selected,
          onTap: () {
            character.from(widget.character);
          }
        );
      },
    );
  }
}
