part of 'package:maid/main.dart';

class EcosystemDropdown extends StatefulWidget {
  const EcosystemDropdown({super.key});

  @override
  State<EcosystemDropdown> createState() => _EcosystemDropdownState();
}

class _EcosystemDropdownState extends State<EcosystemDropdown> {
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
    'AI Ecosystem',
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 16
    )
  );

  Widget buildDropDownRow() => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const SizedBox(width: 8),
      Selector<ArtificialIntelligenceProvider, String>(
        selector: (context, settings) => settings.aiNotifier.type.snakeToSentence(),
        builder: buildOverrideText
      ),
      buildPopupButton()
    ]
  );

  Widget buildOverrideText(BuildContext context, String type, Widget? child) => Text(
    type,
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 16
    )
  );

  Widget buildPopupButton() => PopupMenuButton<String>(
    tooltip: 'Select Llm Ecosystem',
    icon: buildPopupButtonIcon(),
    offset: const Offset(0, 40),
    itemBuilder: itemBuilder,
    onOpened: () => setState(() => open = true),
    onCanceled: () => setState(() => open = false),
    onSelected: (type) async {
      ArtificialIntelligenceProvider.of(context).switchAi(type);
      setState(() => open = false);
    }
  );

  Widget buildPopupButtonIcon() => Icon(
    open ? Icons.arrow_drop_up : Icons.arrow_drop_down,
    color: Theme.of(context).colorScheme.onSurface,
    size: 24,
  );

  List<PopupMenuEntry<String>> itemBuilder(BuildContext context) {
    List<PopupMenuEntry<String>> items = [];

    for (final type in ArtificialIntelligenceNotifier.types) {
      items.add(PopupMenuItem<String>(
        value: type,
        child: Text(type.snakeToSentence())
      ));
    }

    return items;
  }
}