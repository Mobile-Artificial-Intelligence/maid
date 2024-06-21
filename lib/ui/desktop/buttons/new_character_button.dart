import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_data.dart';

class NewCharacterButton extends StatelessWidget {
  const NewCharacterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () {
        AppData.of(context).newCharacter();
      },
      child: const Text(
        "New Character"
      ),
    );
  }
}