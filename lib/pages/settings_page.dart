import 'package:flutter/material.dart';
import 'package:maid/config/theme.dart';

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
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
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
          ],
        ),
      ),
    );
  }

}