part of 'package:maid/main.dart';

class ArtificialIntelligenceDropdown extends StatefulWidget {
  final ArtificialIntelligenceController aiController;

  const ArtificialIntelligenceDropdown({
    super.key, 
    required this.aiController
  });

  @override
  State<ArtificialIntelligenceDropdown> createState() => _ArtificialIntelligenceDropdownState();
}

class _ArtificialIntelligenceDropdownState extends State<ArtificialIntelligenceDropdown> {
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
      ListenableBuilder(
        listenable: widget.aiController,
        builder: buildOverrideText
      ),
      buildPopupButton()
    ]
  );

  Widget buildOverrideText(BuildContext context, Widget? child) => Text(
    widget.aiController.type.snakeToSentence(),
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
    onSelected: (type) {
      MaidState.of(context).switchAi(type);
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

    for (final type in ArtificialIntelligenceController.types) {
      items.add(PopupMenuItem<String>(
        value: type,
        child: Text(type.snakeToSentence())
      ));
    }

    return items;
  }
}