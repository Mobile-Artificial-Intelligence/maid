part of 'package:maid/main.dart';

class RemoteModelDropdown extends StatefulWidget {
  final LlmEcosystem ecosystem;
  final Future<List<String>> Function() getModelOptions;

  const RemoteModelDropdown({super.key, required this.getModelOptions, required this.ecosystem});

  @override
  State<RemoteModelDropdown> createState() => _RemoteModelDropdownState();
}

class _RemoteModelDropdownState extends State<RemoteModelDropdown> {
  List<String> models = [];
  bool open = false;

  void onSelected(String model) {
    ArtificialIntelligence.of(context).setModel(widget.ecosystem, model);
    setState(() => open = false);
  }

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const SizedBox(width: 8),
      buildModelText(),
      buildButtonFuture()
    ]
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

  Future<void> fetchModels() async {
    models = await widget.getModelOptions();
  }

  Widget buildButtonFuture() => FutureBuilder<void>(
    future: fetchModels(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        return buildPopupButton();
      }

      return buildSpinner();
    },
  );

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

  Widget buildPopupButton() => PopupMenuButton<String>(
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