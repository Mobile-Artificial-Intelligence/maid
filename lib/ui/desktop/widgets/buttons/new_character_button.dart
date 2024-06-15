import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/providers/character.dart';
import 'package:provider/provider.dart';

class NewCharacterButton extends StatelessWidget {
  const NewCharacterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppData, Character>(
      builder: buildButton
    );
  }

  Widget buildButton(BuildContext context, AppData appData, Character character, Widget? child) {
    return FilledButton(
      onPressed: () {
        final newCharacter = Character();
        appData.setCurrentCharacter(character, newCharacter);
        character.from(newCharacter);
      },
      child: const Text(
        "New Character"
      ),
    );
  }
}