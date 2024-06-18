import 'package:flutter/material.dart';
import 'package:maid/providers/app_preferences.dart';
import 'package:maid/static/utilities.dart';
import 'package:provider/provider.dart';

class ThemeModeDropdown extends StatefulWidget {
  const ThemeModeDropdown({super.key});

  @override
  State<ThemeModeDropdown> createState() => _ThemeModeDropdownState();
}

class _ThemeModeDropdownState extends State<ThemeModeDropdown> {
  bool open = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppPreferences>(
      builder: (context, appPreferences, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Utilities.capitalizeFirst(appPreferences.themeMode.name),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16
              )
            ),
            PopupMenuButton(
              tooltip: 'Select App Theme Mode',
              icon: Icon(
                open ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: Theme.of(context).colorScheme.onSurface,
                size: 24,
              ),
              offset: const Offset(0, 40),
              itemBuilder: itemBuilder,
              onOpened: () => setState(() => open = true),
              onCanceled: () => setState(() => open = false),
              onSelected: (_) => setState(() => open = false)
            )
          ]
        );
      }
    );
  }

  List<PopupMenuEntry<dynamic>> itemBuilder(BuildContext context) {
    return [
      PopupMenuItem(
        padding: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          title: const Text('System'),
          onTap: () {
            switchThemeMode(context, ThemeMode.system);
            Navigator.pop(context);
          }
        ),
      ),
      PopupMenuItem(
        padding: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          title: const Text('Light'),
          onTap: () {
            switchThemeMode(context, ThemeMode.light);
            Navigator.pop(context);
          }
        ),
      ),
      PopupMenuItem(
        padding: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          title: const Text('Dark'),
          onTap: () {
            switchThemeMode(context, ThemeMode.dark);
            Navigator.pop(context);
          }
        ),
      )
    ];
  }

  void switchThemeMode(BuildContext context, ThemeMode themeMode) {
    final appPreferences = AppPreferences.of(context);
    appPreferences.themeMode = themeMode;
  }
}
