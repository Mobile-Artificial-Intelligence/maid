import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/providers/session.dart';
import 'package:provider/provider.dart';

class ClearSessionsButton extends StatelessWidget {
  const ClearSessionsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppData, Session>(
      builder: buildButton
    );
  }

  Widget buildButton(BuildContext context, AppData appData, Session session, Widget? child) {
    return FilledButton(
      onPressed: () {
        if (!session.chat.tail.finalised) return;
        appData.clearSessions();
      },
      child: const Text(
        "Clear Chats"
      ),
    );
  }
}