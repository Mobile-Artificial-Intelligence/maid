import 'package:flutter/material.dart';
import 'package:maid/classes/providers/characters.dart';

class NewCharacterButton extends StatelessWidget {
  const NewCharacterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () {
        CharacterCollection.of(context).newCharacter();
      },
      child: const Text(
        "New Character"
      ),
    );
  }
}