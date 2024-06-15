import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/providers/session.dart';
import 'package:provider/provider.dart';

class NewSessionButton extends StatelessWidget {
  const NewSessionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: buildButton
    );
  }

  Widget buildButton(BuildContext context, AppData appData, Widget? child) {
    final index = appData.nextSessionIndex;
    return FilledButton(
      onPressed: () {
        appData.currentSession = Session(index);
      },
      child: const Text(
        "New Chat"
      ),
    );
  }
}