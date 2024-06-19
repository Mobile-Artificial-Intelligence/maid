import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:provider/provider.dart';

class ClearSessionsButton extends StatelessWidget {
  const ClearSessionsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: buildButton
    );
  }

  Widget buildButton(BuildContext context, AppData appData, Widget? child) {
    return FilledButton(
      onPressed: () {
        appData.clearSessions();
      },
      child: const Text(
        "Clear Chats"
      ),
    );
  }
}