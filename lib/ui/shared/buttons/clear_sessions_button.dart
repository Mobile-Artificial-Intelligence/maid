import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_data.dart';

/// A button widget that clears all [Session]s.
/// 
/// This button is used to clear all [Session]s in the application.
class ClearSessionsButton extends StatelessWidget {
  const ClearSessionsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: AppData.of(context).clearSessions,
      child: const Text(
        "Clear Chats"
      ),
    );
  }
}