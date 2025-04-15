part of 'package:maid/main.dart';

class RemoteModelDropdown extends StatefulWidget {
  final bool refreshButton;

  const RemoteModelDropdown({super.key, this.refreshButton = false});

  @override
  State<RemoteModelDropdown> createState() => RemoteModelDropdownState();
}

class RemoteModelDropdownState extends State<RemoteModelDropdown> {
  bool open = false;

  void onSelected(String? model) {
    RemoteAIController.instance!.model = model;
    setState(() => open = false);
  }

  Future<bool> getModelOptions() async {
    try {
      return await RemoteAIController.instance!.getModelOptions();
    } 
    catch (exception) {
      if (!mounted) return false;

      showDialog(
        context: context,
        builder: (context) => ErrorDialog(exception: exception),
      );

      return false;
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: RemoteAIController.instance!, 
    builder: buildRow
  );

  Widget buildRow(BuildContext context, Widget? child) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (widget.refreshButton) buildRefreshButton(),
      const SizedBox(width: 8),
      Text(
        RemoteAIController.instance!.model ?? AppLocalizations.of(context)!.noModelSelected,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 16
        )
      ),
      buildFutureBuilder()
    ]
  );

  Widget buildFutureBuilder() => RemoteAIController.instance!.canGetRemoteModels ? FutureBuilder<bool>(
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
    onPressed: () => setState(() => open = false)
  );

  Widget buildPopupButton(BuildContext context, AsyncSnapshot<bool> snapshot) {
    final enabled = snapshot.hasData && snapshot.data != null && snapshot.data!;

    return PopupMenuButton<String>(
      enabled: enabled,
      tooltip: AppLocalizations.of(context)!.selectRemoteModel,
      icon: enabled ? buildPopupButtonIcon() : buildSpinner(),
      offset: const Offset(0, 40),
      itemBuilder: (context) => RemoteAIController.instance!.modelOptions.map(modelBuilder).toList(),
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
    value: model == "none" ? null : model,
    child: Text(model),
    onTap: () => onSelected(model == "none" ? null : model),
  );
}