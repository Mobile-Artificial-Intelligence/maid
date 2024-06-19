import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/providers/app_preferences.dart';
import 'package:maid/providers/user.dart';
import 'package:maid/static/logger.dart';
import 'package:provider/provider.dart';

class LogPanel extends StatelessWidget {
  const LogPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer3<AppData, AppPreferences, User>(
        builder: buildLog,
      ),
    );
  }

  Widget buildLog(BuildContext context, AppData appData, AppPreferences appPreferences, User user, Widget? child) {
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