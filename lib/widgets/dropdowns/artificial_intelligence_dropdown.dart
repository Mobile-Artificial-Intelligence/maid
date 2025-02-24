part of 'package:maid/main.dart';

class ArtificialIntelligenceDropdown extends StatefulWidget {
  final ArtificialIntelligenceController aiController;

  const ArtificialIntelligenceDropdown({
    super.key, 
    required this.aiController
  });

  @override
  State<ArtificialIntelligenceDropdown> createState() => ArtificialIntelligenceDropdownState();
}

class ArtificialIntelligenceDropdownState extends State<ArtificialIntelligenceDropdown> {
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
    AppLocalizations.of(context)!.aiEcosystem,
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
    widget.aiController.getTypeLocale(context),
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 16
    )
  );

  Widget buildPopupButton() => PopupMenuButton<String>(
    tooltip: AppLocalizations.of(context)!.selectAiEcosystem,
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

    for (final type in ArtificialIntelligenceController.getTypes(context).entries) {
      items.add(PopupMenuItem<String>(
        padding: EdgeInsets.all(8),
        value: type.key,
        child: Text(type.value)
      ));
    }

    return items;
  }
}