part of 'package:maid/main.dart';

class ThemeModeDropdown extends StatefulWidget {
  final AppSettings settings;
  
  const ThemeModeDropdown({
    super.key, 
    required this.settings
  });

  @override
  State<ThemeModeDropdown> createState() => _ThemeModeDropdownState();
}

class _ThemeModeDropdownState extends State<ThemeModeDropdown> {
  bool open = false;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.max,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      buildTitle(),
      buildDropDownRow()
    ]
  );

  Widget buildTitle() => Text(
    AppLocalizations.of(context)!.themeMode,
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 16
    )
  );

  Widget buildDropDownRow() => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      ListenableBuilder(
        listenable: widget.settings,
        builder: buildThemeModeText
      ),
      buildPopupButton()
    ]
  );

  Widget buildThemeModeText(BuildContext context, Widget? child) => Text(
    widget.settings.themeMode.getLocale(context),
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 16
    )
  );

  Widget buildPopupButton() => PopupMenuButton<ThemeMode>(
    tooltip: AppLocalizations.of(context)!.selectThemeMode,
    icon: buildPopupButtonIcon(),
    offset: const Offset(0, 40),
    itemBuilder: itemBuilder,
    onOpened: () => setState(() => open = true),
    onCanceled: () => setState(() => open = false),
    onSelected: (themeMode) {
      setState(() => open = false);
      widget.settings.themeMode = themeMode;
    }
  );

  Widget buildPopupButtonIcon() => Icon(
    open ? Icons.arrow_drop_up : Icons.arrow_drop_down,
    color: Theme.of(context).colorScheme.onSurface,
    size: 24,
  );

  List<PopupMenuEntry<ThemeMode>> itemBuilder(BuildContext context) => [
    PopupMenuItem(
      padding: EdgeInsets.all(8),
      value: ThemeMode.system,
      child: Text(AppLocalizations.of(context)!.themeModeSystem)
    ),
    PopupMenuItem(
      padding: EdgeInsets.all(8),
      value: ThemeMode.light,
      child: Text(AppLocalizations.of(context)!.themeModeLight)
    ),
    PopupMenuItem(
      padding: EdgeInsets.all(8),
      value: ThemeMode.dark,
      child: Text(AppLocalizations.of(context)!.themeModeDark)
    )
  ];
}