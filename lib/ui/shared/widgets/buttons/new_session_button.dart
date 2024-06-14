import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/providers/session.dart';
import 'package:provider/provider.dart';

class NewSessionButton extends StatelessWidget {
  const NewSessionButton({super.key});

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
        final newSession = Session();
        appData.currentSession = newSession;
        session.from(newSession);
      },
      child: const Text(
        "New Chat"
      ),
    );
  }
}