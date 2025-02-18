part of 'package:maid/main.dart';

class RemoteModelDropdown extends StatefulWidget {
  final LlmEcosystem ecosystem;
  final bool refreshButton;

  const RemoteModelDropdown({super.key, required this.ecosystem, this.refreshButton = false}) : 
    assert(ecosystem != LlmEcosystem.llamaCPP);

  @override
  State<RemoteModelDropdown> createState() => _RemoteModelDropdownState();
}

class _RemoteModelDropdownState extends State<RemoteModelDropdown> {
  static Map<LlmEcosystem, List<String>> modelOptions = {};
  bool open = false;

  @override
  void initState() {
    super.initState();
  }

  void onSelected(String model) {
    ArtificialIntelligence.of(context).setModel(widget.ecosystem, model);
    setState(() => open = false);
  }

  Future<List<String>> getModelOptions() async {
    try {
      return await ArtificialIntelligence.of(context).getModelOptions(widget.ecosystem);
    } 
    catch (exception) {
      if (!mounted) return [];

      showDialog(
        context: context,
        builder: (context) => ErrorDialog(exception: exception),
      );

      return [];
    }
  }

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (widget.refreshButton) buildRefreshButton(),
      const SizedBox(width: 8),
      buildModelText(),
      buildHashSelector()
    ]
  );

  Widget buildRefreshButton() => IconButton(
    icon: Icon(
      Icons.refresh,
      color: Theme.of(context).colorScheme.onSurface,
      size: 24
    ),
    onPressed: () => setState(() => modelOptions.remove(widget.ecosystem))
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

  Widget buildHashSelector() => Selector<ArtificialIntelligence, String?>(
    selector: (context, ai) => ai.getEcosystemHash(widget.ecosystem),
    builder: buildFutureBuilder
  );

  Widget buildFutureBuilder(BuildContext context, String? hash, Widget? child) => FutureBuilder<List<String>?>(
    future: getModelOptions(),
    builder: buildPopupButton
  );

  Widget buildPopupButton(BuildContext context, AsyncSnapshot<List<String>?> snapshot) {
    final enabled = snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty;

    return PopupMenuButton<String>(
      enabled: enabled,
      tooltip: 'Select Remote Model',
      icon: enabled ? buildPopupButtonIcon() : buildSpinner(),
      offset: const Offset(0, 40),
      itemBuilder: (context) => snapshot.data!.map(modelBuilder).toList(),
      onOpened: () => setState(() => open = true),
      onCanceled: () => setState(() => open = false)
    );
  }

  Widget buildPopupButtonIcon() => Icon(
    open ? Icons.arrow_drop_up : Icons.arrow_drop_down,
    color: Theme.of(context).colorScheme.onSurface,
    size: 24,
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

  PopupMenuEntry<String> modelBuilder(String model) => PopupMenuItem(
    padding: EdgeInsets.all(8),
    value: model,
    child: Text(model),
    onTap: () => onSelected(model),
  );
}