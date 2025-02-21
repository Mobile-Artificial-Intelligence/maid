part of 'package:maid/main.dart';

class ArtificialIntelligenceSettings extends StatelessWidget {
  const ArtificialIntelligenceSettings({super.key});

  @override
  Widget build(BuildContext context) => Selector<ArtificialIntelligence, ArtificialIntelligenceContext>(
    selector: (context, ai) => ai.context,
    builder: buildColumn,
  );

  Widget buildColumn(BuildContext context, ArtificialIntelligenceContext aiContext, Widget? child) => Column(
    children: [
      Divider(endIndent: 0, indent: 0, height: 32),
      Text(
        '${ArtificialIntelligence.of(context).ecosystem.name.pascalToSentence()} Settings',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      aiContext is RemoteArtificialIntelligenceContext
        ? buildRemoteSettings(context)
        : buildModelLoaderRow(context),
    ],
  );

  Widget buildRemoteSettings(BuildContext context) => Column(
    children: [
      buildRemoteModel(),
      const SizedBox(height: 8),
      if (ArtificialIntelligence.of(context).ecosystem == ArtificialIntelligenceEcosystem.ollama) buildLocalSearchSwitch(context),
      BaseUrlTextField(),
      const SizedBox(height: 8),
      ApiKeyTextField(),
    ]
  );

  Widget buildRemoteModel() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        'Remote Model',
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      RemoteModelDropdown(
        refreshButton: true,
      ),
    ],
  );

  Widget buildModelLoaderRow(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.max,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      buildModelLoaderTitle(),
      buildModelLoader(context),
    ],
  );

  Widget buildModelLoader(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      buildModelText(),
      buildModelLoaderButtonSelector(),
    ],
  );

  Widget buildModelLoaderButtonSelector() => Selector<ArtificialIntelligence, bool>(
    selector: (context, ai) => ai.fileLoading,
    builder: modelLoaderButtonBuilder,
  );

  Widget modelLoaderButtonBuilder(BuildContext context, bool loading, Widget? child) => loading
    ? buildSpinner()
    : buildModelLoaderButton(context);

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

  Widget buildModelLoaderButton(BuildContext context) => IconButton(
    onPressed: ArtificialIntelligence.of(context).loadModel, 
    icon: const Icon(Icons.folder)
  );

  Widget buildModelLoaderTitle() => Expanded(
    child: Text(
      'Llama CPP Model',
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    )
  );

  Widget buildModelText() => Selector<ArtificialIntelligence, String?>(
    selector: (context, ai) => ai.model,
    builder: modelTextBuilder,
  );

  Widget modelTextBuilder(BuildContext context, String? model, Widget? child) => Text(
    model?.split('/').last ?? 'No model loaded',
    overflow: TextOverflow.ellipsis,
    maxLines: 1,
  );

  Widget buildLocalSearchSwitch(BuildContext context) => Column(
    children: [
      buildLocalSearchSwitchRow(context),
      const SizedBox(height: 8),
    ],
  );

  Widget buildLocalSearchSwitchRow(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        'Search Local Network',
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      Selector<ArtificialIntelligence, bool?>(
        selector: (context, ai) => ai.searchLocalNetworkForOllama,
        builder: buildSwitch,
      ),
    ],
  );

  Widget buildSwitch(BuildContext context, bool? searchLocalNetworkForOllama, Widget? child) => Switch(
    value: searchLocalNetworkForOllama ?? false,
    onChanged: (value) => onLocalSearchChanged(context, value),
  );

  void onLocalSearchChanged(BuildContext context, bool value) {
    final ai = ArtificialIntelligence.of(context);
    if (
      (Platform.isAndroid || Platform.isIOS) &&
      ai.searchLocalNetworkForOllama == null && 
      value
    ) {
      // Show alert dialog informing the user of the permissions required
      showDialog(
        context: context,
        builder: buildPermissionsAlert,
      );
      return;
    }

    ai.searchLocalNetworkForOllama = value;
  }

  Widget buildPermissionsAlert(BuildContext context) => AlertDialog(
    title: const Text(
      'Local Network Search',
      textAlign: TextAlign.center,
    ),
    content: Text(
      'This feature requires additional permissions to search your local network for Ollama instances.',
      textAlign: TextAlign.center,
    ),
    actionsAlignment: MainAxisAlignment.spaceEvenly,
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () => closePermissionsAlert(context),
        child: const Text('OK'),
      ),
    ],
  );

  void closePermissionsAlert(BuildContext context) async {
    final ai = ArtificialIntelligence.of(context);
    Navigator.of(context).pop();

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdk = androidInfo.version.sdkInt;

    bool granted;
    if (sdk <= 32) {
      // ACCESS_FINE_LOCATION is required
      granted = await Permission.location.request().isGranted;
    } 
    else {
      // NEARBY_WIFI_DEVICES is required
      granted = await Permission.nearbyWifiDevices.request().isGranted;
    }

    if (!granted) return;

    ai.searchLocalNetworkForOllama = true;
  }
}