import 'package:flutter/material.dart';
import 'package:maid/enumerators/app_layout.dart';
import 'package:maid/classes/providers/app_preferences.dart';
import 'package:maid/classes/static/utilities.dart';
import 'package:provider/provider.dart';

class AppLayoutDropdown extends StatefulWidget {
  const AppLayoutDropdown({super.key});

  @override
  State<AppLayoutDropdown> createState() => _AppLayoutDropdownState();
}

class _AppLayoutDropdownState extends State<AppLayoutDropdown> {
  bool open = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppPreferences>(
      builder: (context, appPreferences, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Utilities.capitalizeFirst(appPreferences.appLayout.name),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16
              )
            ),
            PopupMenuButton(
              tooltip: 'Select App Layout Mode',
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
            switchAppLayout(context, AppLayout.system);
            Navigator.pop(context);
          }
        ),
      ),
      PopupMenuItem(
        padding: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          title: const Text('Mobile'),
          onTap: () {
            switchAppLayout(context, AppLayout.mobile);
            Navigator.pop(context);
          }
        ),
      ),
      PopupMenuItem(
        padding: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          title: const Text('Desktop'),
          onTap: () {
            switchAppLayout(context, AppLayout.desktop);
            Navigator.pop(context);
          }
        ),
      )
    ];
  }

  void switchAppLayout(BuildContext context, AppLayout appLayout) {
    final appPreferences = AppPreferences.of(context);
    appPreferences.appLayout = appLayout;
  }
}
