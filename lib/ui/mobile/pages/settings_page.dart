import 'package:flutter/material.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/providers/user.dart';
import 'package:maid/static/logger.dart';
import 'package:maid/main.dart';
import 'package:maid/ui/mobile/widgets/appbars/generic_app_bar.dart';
import 'package:maid_ui/maid_ui.dart';
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
      body: Consumer<MainProvider>(
        builder: (context, mainProvider, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                    child: Row(
                    children: [
                      const Expanded(
                        child: Text("Theme Mode"),
                      ),
                      DropdownMenu<ThemeMode>(
                        hintText: "Select Theme Mode",
                        inputDecorationTheme: InputDecorationTheme(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: Theme.of(context).colorScheme.secondary,
                          filled: true,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                        ),
                        dropdownMenuEntries: const [
                          DropdownMenuEntry<ThemeMode>(
                            value: ThemeMode.system,
                            label: "System",
                          ),
                          DropdownMenuEntry<ThemeMode>(
                            value: ThemeMode.light,
                            label: "Light",
                          ),
                          DropdownMenuEntry<ThemeMode>(
                            value: ThemeMode.dark,
                            label: "Dark",
                          )
                        ],
                        onSelected: (ThemeMode? value) {
                          if (value != null) {
                            mainProvider.themeMode = value;
                          }
                        },
                        initialSelection: mainProvider.themeMode,
                        width: 200,
                      )
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
                      context.read<Session>().newSession();
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
                    child: CodeBox(code: Logger.getLog)),
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
