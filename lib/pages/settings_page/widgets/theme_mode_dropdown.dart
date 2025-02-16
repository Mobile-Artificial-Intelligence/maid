part of 'package:maid/main.dart';

class ThemeModeDropdown extends StatefulWidget {
  const ThemeModeDropdown({super.key});

  @override
  State<ThemeModeDropdown> createState() => _ThemeModeDropdownState();
}

class _ThemeModeDropdownState extends State<ThemeModeDropdown> {
  bool open = false;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildTitle(),
        buildDropDownRow()
      ]
    )
  );

  Widget buildTitle() => Text(
    'Theme Mode',
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 16
    )
  );

  Widget buildDropDownRow() => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Selector<AppSettings, ThemeMode>(
        selector: (context, settings) => settings.themeMode,
        builder: buildThemeModeText
      ),
      buildPopupButton()
    ]
  );

  Widget buildThemeModeText(BuildContext context, ThemeMode themeMode, Widget? child) => Text(
    themeMode.name.firstCapitalized,
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 16
    )
  );

  Widget buildPopupButton() => PopupMenuButton<ThemeMode>(
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
    onSelected: (themeMode) {
      setState(() => open = false);
      AppSettings.of(context).themeMode = themeMode;
    }
  );

  List<PopupMenuEntry<ThemeMode>> itemBuilder(BuildContext context) => [
    PopupMenuItem(
      padding: EdgeInsets.all(8),
      value: ThemeMode.system,
      child: const Text('System')
    ),
    PopupMenuItem(
      padding: EdgeInsets.all(8),
      value: ThemeMode.light,
      child: const Text('Light')
    ),
    PopupMenuItem(
      padding: EdgeInsets.all(8),
      value: ThemeMode.dark,
      child: const Text('Dark')
    )
  ];
}