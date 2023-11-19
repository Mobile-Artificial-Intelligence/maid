import 'package:flutter/material.dart';
import 'package:maid/static/logger.dart';
import 'package:maid/static/theme.dart';
import 'package:maid/widgets/chat_widgets/code_box.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsBody extends StatefulWidget {
  const SettingsBody({super.key});

  @override
  State<SettingsBody> createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<SettingsBody> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Theme (Light/Dark)'),
            value: (MaidTheme.theme == MaidTheme.darkTheme) ? true : false,
            onChanged: (value) {
              if (value) {
                MaidTheme.setTheme(ThemeType.dark);
              } else {
                MaidTheme.setTheme(ThemeType.light);
              }
            },
          ),
          FilledButton(
            onPressed: () async {
              var prefs = await SharedPreferences.getInstance();
              prefs.clear();
              setState(() {});
            },
            child: Text("Clear Cache",
                style: Theme.of(context).textTheme.labelLarge),
          ),
          Divider(
            height: 20,
            indent: 10,
            endIndent: 10,
            color: Theme.of(context).colorScheme.primary,
          ),
          Padding(
              padding: const EdgeInsets.all(10),
              child: CodeBox(code: Logger.getLog)),
        ],
      ),
    );
  }
}
