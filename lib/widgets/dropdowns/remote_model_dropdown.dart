part of 'package:maid/main.dart';

class RemoteModelDropdown extends StatefulWidget {
  final RemoteArtificialIntelligenceController aiController;
  final bool refreshButton;

  const RemoteModelDropdown({super.key, this.refreshButton = false, required this.aiController});

  @override
  State<RemoteModelDropdown> createState() => RemoteModelDropdownState();
}

class RemoteModelDropdownState extends State<RemoteModelDropdown> {
  bool open = false;

  void onSelected(String model) {
    widget.aiController.model = model;
    setState(() => open = false);
  }

  Future<List<String>> getModelOptions() async {
    try {
      return await widget.aiController.getModelOptions();
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
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.aiController, 
    builder: buildRow
  );

  Widget buildRow(BuildContext context, Widget? child) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (widget.refreshButton) buildRefreshButton(),
      const SizedBox(width: 8),
      Text(
        widget.aiController.model ?? AppLocalizations.of(context)!.noModelSelected,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 16
        )
      ),
      
    ]
  );

  Widget buildFutureBuilder() => widget.aiController.canGetRemoteModels ? FutureBuilder<List<String>?>(
    future: getModelOptions(),
    builder: buildPopupButton
  ) : const SizedBox.shrink();

  Widget buildRefreshButton() => IconButton(
    tooltip: AppLocalizations.of(context)!.refreshRemoteModels,
    icon: Icon(
      Icons.refresh,
      color: Theme.of(context).colorScheme.onSurface,
      size: 24
    ),
    onPressed: () => setState(() {})
  );

  Widget buildPopupButton(BuildContext context, AsyncSnapshot<List<String>?> snapshot) {
    final enabled = snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty;

    return PopupMenuButton<String>(
      enabled: enabled,
      tooltip: AppLocalizations.of(context)!.selectRemoteModel,
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