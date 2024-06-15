import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/providers/session.dart';

class NewSessionButton extends StatelessWidget {
  const NewSessionButton({super.key});

  @override
  Widget build(BuildContext context) {
    final index = AppData.of(context).nextSessionIndex;

    return FilledButton(
      onPressed: () {
        AppData.of(context).currentSession = Session(index);
      },
      child: const Text(
        "New Chat"
      ),
    );
  }
}