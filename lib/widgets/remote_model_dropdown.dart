part of 'package:maid/main.dart';

class RemoteModelDropdown extends StatefulWidget {
  const RemoteModelDropdown({super.key});

  @override
  State<RemoteModelDropdown> createState() => _RemoteModelDropdownState();
}

class _RemoteModelDropdownState extends State<RemoteModelDropdown> {
  List<String> models = [];
  bool open = false;

  @override
  void initState() {
    super.initState();
    loadModels();
  }

  void loadModels() async {
    models = await ArtificialIntelligence.of(context).getModelOptions();
    setState(() => open = false);
  }

  void onSelected(String model) {
    ArtificialIntelligence.of(context).ollamaModel = model;
    setState(() => open = false);
  }

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const SizedBox(width: 8),
      buildModelText(),
      buildPopupButton()
    ]
  );

  Widget buildModelText() => Selector<ArtificialIntelligence, String?>(
    selector: (context, ai) => ai.ollamaModel,
    builder: (context, model, child) => Text(
      model ?? 'No model selected',
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 16
      )
    ),
  );

  Widget buildPopupButton() => PopupMenuButton<String>(
    tooltip: 'Select Remote Model',
    icon: Icon(
      open ? Icons.arrow_drop_up : Icons.arrow_drop_down,
      color: Theme.of(context).colorScheme.onSurface,
      size: 24,
    ),
    offset: const Offset(0, 40),
    itemBuilder: itemBuilder,
    onOpened: () => setState(() => open = true),
    onCanceled: () => setState(() => open = false)
  );

  List<PopupMenuEntry<String>> itemBuilder(BuildContext context) {
    return models.map((model) => PopupMenuItem(
      padding: EdgeInsets.all(8),
      value: model,
      child: Text(model),
      onTap: () => onSelected(model),
    )).toList();
  }
}