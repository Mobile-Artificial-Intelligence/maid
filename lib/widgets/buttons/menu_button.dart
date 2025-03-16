part of 'package:maid/main.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({super.key});

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
    icon: const Icon(
      Icons.more_vert
    ),
    itemBuilder: itemBuilder,
    onSelected: (value) => Navigator.of(context).pushNamed(value),
  );

  List<PopupMenuEntry<String>> itemBuilder(BuildContext context) => [
    PopupMenuItem(
      value: 'settings',
      child: Text(
        AppLocalizations.of(context)!.settingsTitle
      ),
    ),
    PopupMenuItem(
      value: 'about',
      child: Text(
        AppLocalizations.of(context)!.aboutTitle
      ),
    ),
  ];
}