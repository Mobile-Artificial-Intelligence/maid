import 'package:flutter/material.dart';
import 'package:maid/providers/character.dart';

class CharacterBrowserTile extends StatelessWidget {
  final Character character;

  const CharacterBrowserTile({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return GridTile(
      child: Container(
        color: Theme.of(context).colorScheme.primary,
        child: Stack(
          children: [
            Image.file(character.profile),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Text(
                  character.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        )
      )
    );
  }
}

