import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/providers/character.dart';
import 'package:provider/provider.dart';

class NewCharacterButton extends StatelessWidget {
  const NewCharacterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: buildButton
    );
  }

  Widget buildButton(BuildContext context, AppData appData, Widget? child) {
    return FilledButton(
      onPressed: () {
        appData.currentCharacter = Character();
      },
      child: const Text(
        "New Character"
      ),
    );
  }
}