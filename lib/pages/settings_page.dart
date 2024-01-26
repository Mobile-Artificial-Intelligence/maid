import 'package:flutter/material.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/providers/model.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/static/logger.dart';
import 'package:maid/main.dart';
import 'package:maid/widgets/chat_widgets/code_box.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
          ),
        ),
        title: const Text("Settings"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Theme (Light/Dark)'),
              value: Provider.of<MainProvider>(context, listen: false).isDarkMode,
              onChanged: (value) {
                Provider.of<MainProvider>(context, listen: false).toggleTheme();
              },
            ),
            FilledButton(
              onPressed: () {
                SharedPreferences.getInstance().then((prefs) {
                  prefs.clear();
                  context.read<Model>().init();
                  context.read<Character>().init();
                  context.read<Session>().init();
                  setState(() {
                    Logger.clear();
                  });
                });
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
      )
    );
  }
}
