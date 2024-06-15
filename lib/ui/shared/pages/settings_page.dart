import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/providers/app_preferences.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/providers/user.dart';
import 'package:maid/static/logger.dart';
import 'package:maid/ui/mobile/widgets/appbars/generic_app_bar.dart';
import 'package:maid/ui/shared/widgets/code_box.dart';
import 'package:maid/ui/shared/widgets/dropdowns/app_layout_dropdown.dart';
import 'package:maid/ui/shared/widgets/dropdowns/theme_mode_dropdown.dart';
import 'package:provider/provider.dart';
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
      body: Consumer<AppPreferences>(
        builder: (context, mainProvider, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
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
                      mainProvider.reset();
                      context.read<User>().reset();
                      context.read<Character>().reset();
                      context.read<Session>().newSession(1);
                      context.read<AppData>().reset();
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
                    color:
                        Color.lerp(Colors.red, Colors.green, ram.clamp(0, 8) / 8) ??
                            Colors.red,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
