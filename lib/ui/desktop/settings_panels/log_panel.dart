import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_preferences.dart';
import 'package:maid/classes/providers/artificial_intelligence.dart';
import 'package:maid/classes/providers/characters.dart';
import 'package:maid/classes/providers/sessions.dart';
import 'package:maid/classes/providers/user.dart';
import 'package:maid/classes/static/logger.dart';
import 'package:provider/provider.dart';

class LogPanel extends StatelessWidget {
  const LogPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer5<ArtificialIntelligence, CharacterCollection, Sessions, User, AppPreferences>(
        builder: buildLog,
      ),
    );
  }

  Widget buildLog(BuildContext context, ArtificialIntelligence ai, CharacterCollection characters, Sessions sessions, User user, AppPreferences appPreferences, Widget? child) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.black,
      child: SelectableText(
        Logger.getLog,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'monospace',
        ),
      )
    );
  }
}