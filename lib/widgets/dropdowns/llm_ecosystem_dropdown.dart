part of 'package:maid/main.dart';

class LlmEcosystemDropdown extends StatefulWidget {
  const LlmEcosystemDropdown({super.key});

  @override
  State<LlmEcosystemDropdown> createState() => _LlmEcosystemDropdownState();
}

class _LlmEcosystemDropdownState extends State<LlmEcosystemDropdown> {
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
    'Llm Ecosystem',
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 16
    )
  );

  Widget buildDropDownRow() => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const SizedBox(width: 8),
      Selector<ArtificialIntelligence, LlmEcosystem>(
        selector: (context, settings) => settings.ecosystem,
        builder: buildOverrideText
      ),
      buildPopupButton()
    ]
  );

  Widget buildOverrideText(BuildContext context, LlmEcosystem ecosystem, Widget? child) => Text(
    ecosystem.name.pascalToSentence(),
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 16
    )
  );

  Widget buildPopupButton() => PopupMenuButton<LlmEcosystem>(
    tooltip: 'Select Llm Ecosystem',
    icon: buildPopupButtonIcon(),
    offset: const Offset(0, 40),
    itemBuilder: itemBuilder,
    onOpened: () => setState(() => open = true),
    onCanceled: () => setState(() => open = false),
    onSelected: (ecosystem) {
      ArtificialIntelligence.of(context).ecosystem = ecosystem;
      setState(() => open = false);
    }
  );

  Widget buildPopupButtonIcon() => Icon(
    open ? Icons.arrow_drop_up : Icons.arrow_drop_down,
    color: Theme.of(context).colorScheme.onSurface,
    size: 24,
  );

  List<PopupMenuEntry<LlmEcosystem>> itemBuilder(BuildContext context) {
    List<PopupMenuEntry<LlmEcosystem>> items = [];

    for (final ecosystem in LlmEcosystem.values) {
      items.add(PopupMenuItem<LlmEcosystem>(
        value: ecosystem,
        child: Text(ecosystem.name.pascalToSentence())
      ));
    }

    return items;
  }
}