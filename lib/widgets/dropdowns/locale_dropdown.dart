part of 'package:maid/main.dart';

class LocaleDropdown extends StatefulWidget {
  final AppSettings settings;
  
  const LocaleDropdown({
    super.key, 
    required this.settings
  });

  @override
  State<LocaleDropdown> createState() => LocaleDropdownState();
}

class LocaleDropdownState extends State<LocaleDropdown> {
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
    AppLocalizations.of(context)!.localeTitle,
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
        builder: buildLocaleText
      ),
      buildPopupButton()
    ]
  );

  Widget buildLocaleText(BuildContext context, Widget? child) => Text(
    widget.settings.locale != null ? 
      lookupAppLocalizations(widget.settings.locale!).friendlyName : 
      AppLocalizations.of(context)!.defaultLocale,
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 16
    )
  );

  Widget buildPopupButton() => PopupMenuButton<Locale>(
    tooltip: AppLocalizations.of(context)!.selectThemeMode,
    icon: buildPopupButtonIcon(),
    offset: const Offset(0, 40),
    itemBuilder: itemBuilder,
    onOpened: () => setState(() => open = true),
    onCanceled: () => setState(() => open = false),
    onSelected: (locale) {
      setState(() => open = false);

      if (locale.languageCode == 'null') {
        widget.settings.locale = null;
      }
      else {
        widget.settings.locale = locale;
      }
    }
  );

  Widget buildPopupButtonIcon() => Icon(
    open ? Icons.arrow_drop_up : Icons.arrow_drop_down,
    color: Theme.of(context).colorScheme.onSurface,
    size: 24,
  );

  List<PopupMenuEntry<Locale>> itemBuilder(BuildContext context) {
    final locales = AppLocalizations.supportedLocales;
    List<PopupMenuEntry<Locale>> items = [
      PopupMenuItem(
        padding: EdgeInsets.all(8),
        value: Locale('null'),
        child: Text(AppLocalizations.of(context)!.defaultLocale)
      )
    ];
    
    for (final locale in locales) {
      final appLocalization = lookupAppLocalizations(locale);

      items.add(
        PopupMenuItem(
          padding: EdgeInsets.all(8),
          value: locale,
          child: Text(appLocalization.friendlyName)
        )
      );
    }

    return items;
  }
}