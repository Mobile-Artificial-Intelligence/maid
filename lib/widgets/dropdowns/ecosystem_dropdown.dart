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
      Selector<ArtificialIntelligence, ArtificialIntelligenceEcosystem>(
        selector: (context, settings) => settings.ecosystem,
        builder: buildOverrideText
      ),
      buildPopupButton()
    ]
  );

  Widget buildOverrideText(BuildContext context, ArtificialIntelligenceEcosystem ecosystem, Widget? child) => Text(
    ecosystem.name.pascalToSentence(),
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 16
    )
  );

  Widget buildPopupButton() => PopupMenuButton<ArtificialIntelligenceEcosystem>(
    tooltip: 'Select Llm Ecosystem',
    icon: buildPopupButtonIcon(),
    offset: const Offset(0, 40),
    itemBuilder: itemBuilder,
    onOpened: () => setState(() => open = true),
    onCanceled: () => setState(() => open = false),
    onSelected: (ecosystem) async {
      final ai = ArtificialIntelligence.of(context);
      final oldEcosystem = ai.ecosystem;
      ArtificialIntelligence.of(context).ecosystem = ecosystem;
      await ai.switchContext(oldEcosystem);
      setState(() => open = false);
    }
  );

  Widget buildPopupButtonIcon() => Icon(
    open ? Icons.arrow_drop_up : Icons.arrow_drop_down,
    color: Theme.of(context).colorScheme.onSurface,
    size: 24,
  );

  List<PopupMenuEntry<ArtificialIntelligenceEcosystem>> itemBuilder(BuildContext context) {
    List<PopupMenuEntry<ArtificialIntelligenceEcosystem>> items = [];

    for (final ecosystem in ArtificialIntelligenceEcosystem.values) {
      items.add(PopupMenuItem<ArtificialIntelligenceEcosystem>(
        value: ecosystem,
        child: Text(ecosystem.name.pascalToSentence())
      ));
    }

    return items;
  }
}