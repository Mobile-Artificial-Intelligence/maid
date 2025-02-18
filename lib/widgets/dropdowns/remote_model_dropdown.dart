part of 'package:maid/main.dart';

class RemoteModelDropdown extends StatefulWidget {
  final LlmEcosystem ecosystem;
  final bool refreshButton;

  const RemoteModelDropdown({super.key, required this.ecosystem, this.refreshButton = false});

  @override
  State<RemoteModelDropdown> createState() => _RemoteModelDropdownState();
}

class _RemoteModelDropdownState extends State<RemoteModelDropdown> {
  bool open = false;

  @override
  void initState() {
    super.initState();
  }

  void onSelected(String model) {
    ArtificialIntelligence.of(context).setModel(widget.ecosystem, model);
    setState(() => open = false);
  }

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (widget.refreshButton) buildRefreshButton(),
      const SizedBox(width: 8),
      buildModelText(),
      buildModelsSelector()
    ]
  );

  Widget buildRefreshButton() => IconButton(
    icon: Icon(
      Icons.refresh,
      color: Theme.of(context).colorScheme.onSurface,
      size: 24
    ),
    onPressed: () => ArtificialIntelligence.of(context).updateModelOptions()
  );

  Widget buildModelText() => Selector<ArtificialIntelligence, String?>(
    selector: (context, ai) => ai.model[widget.ecosystem],
    builder: (context, model, child) => Text(
      model ?? 'No model selected',
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 16
      )
    ),
  );

  Widget buildModelsSelector() => Selector<ArtificialIntelligence, List<String>?>(
    selector: (context, ai) => ai.modelOptions[widget.ecosystem],
    builder: buildButtonOrSpinner
  );

  Widget buildButtonOrSpinner(BuildContext context, List<String>? models, Widget? child) {
    if(models == null) {
      return SizedBox.shrink();
    }

    if (models.isEmpty) {
      return buildSpinner();
    }

    return buildPopupButton(models);
  }

  Widget buildSpinner() => const Padding(
    padding: EdgeInsets.all(8.0),
    child: SizedBox(
      width: 24,
      height: 24,
      child: Center(
        child: CircularProgressIndicator(strokeWidth: 3.0),
      ),
    ),
  );

  Widget buildPopupButton(List<String> models) => PopupMenuButton<String>(
    tooltip: 'Select Remote Model',
    icon: Icon(
      open ? Icons.arrow_drop_up : Icons.arrow_drop_down,
      color: Theme.of(context).colorScheme.onSurface,
      size: 24,
    ),
    offset: const Offset(0, 40),
    itemBuilder: (context) => models.map(modelBuilder).toList(),
    onOpened: () => setState(() => open = true),
    onCanceled: () => setState(() => open = false)
  );

  PopupMenuEntry<String> modelBuilder(String model) => PopupMenuItem(
    padding: EdgeInsets.all(8),
    value: model,
    child: Text(model),
    onTap: () => onSelected(model),
  );
}