import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:maid/classes/providers/app_preferences.dart';
import 'package:maid/classes/providers/user.dart';
import 'package:maid/classes/static/logger.dart';
import 'package:maid/ui/shared/layout/generic_app_bar.dart';
import 'package:maid/ui/shared/utilities/code_box.dart';
import 'package:maid/ui/shared/dropdowns/app_layout_dropdown.dart';
import 'package:maid/ui/shared/dropdowns/theme_mode_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_info2/system_info2.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static int ram = SysInfo.getTotalPhysicalMemory() ~/ (1024 * 1024 * 1024);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GenericAppBar(title: "App Settings"),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text("Auto Text to Speech"),
            value: AppPreferences.of(context).autoTextToSpeech,
            onChanged: (value) {
              AppPreferences.of(context).autoTextToSpeech = value;
            },
          ),
          const Padding(
            padding: EdgeInsets.all(8),
              child: Row(
                children: [
                Expanded(
                  child: Text("Theme Mode"),
                ),
                ThemeModeDropdown()
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8),
              child: Row(
                children: [
                Expanded(
                  child: Text("Application Layout"),
                ),
                AppLayoutDropdown()
              ],
            ),
          ),
          FilledButton(
            onPressed: () {
              SharedPreferences.getInstance().then((prefs) {
                prefs.clear();
                AppPreferences.of(context).reset();
                User.of(context).reset();
                AppData.of(context).reset();
                setState(() {
                  Logger.clear();
                });
              });
            },
            child: const Text("Clear Cache"),
          ),
          Divider(
            height: 20,
            indent: 10,
            endIndent: 10,
            color: Theme.of(context).colorScheme.primary,
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: CodeBox(code: Logger.getLog)
          ),
          Text(
            ram == -1 ? 'RAM: Unknown' : 'RAM: $ram GB',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color.lerp(
                Colors.red, 
                Colors.green, 
                ram.clamp(0, 8) / 8
              ),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
