import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';

class NewSessionButton extends StatelessWidget {
  const NewSessionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () {
        AppData.of(context).newSession();
      },
      child: const Text(
        "New Chat"
      ),
    );
  }
}