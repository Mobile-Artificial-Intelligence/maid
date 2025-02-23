part of 'package:maid/main.dart';

class ArtificialIntelligenceSettings extends StatelessWidget {
  final ArtificialIntelligenceNotifier aiController;
  
  const ArtificialIntelligenceSettings({
    super.key, 
    required this.aiController
  });

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: aiController,
    builder: buildColumn,
  );

  Widget buildColumn(BuildContext context, Widget? child) => Column(
    children: [
      Divider(endIndent: 0, indent: 0, height: 32),
      Text(
        '${aiController.type.snakeToSentence()} Settings',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      aiController is RemoteArtificialIntelligenceNotifier
        ? buildRemoteSettings(context)
        : buildModelLoaderRow(context),
    ],
  );

  Widget buildRemoteSettings(BuildContext context) => Column(
    children: [
      buildRemoteModel(),
      const SizedBox(height: 8),
      if (aiController is OllamaNotifier) buildLocalSearchSwitch(context),
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
        aiController: aiController as RemoteArtificialIntelligenceNotifier,
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
      buildModelLoaderButtonSelector(context),
    ],
  );

  Widget buildModelLoaderButtonSelector(BuildContext context) => (aiController as LlamaCppNotifier).loading
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
    onPressed: (aiController as LlamaCppNotifier).pickModel, 
    icon: const Icon(Icons.folder)
  );

  Widget buildModelLoaderTitle() => Expanded(
    child: Text(
      'Llama CPP Model',
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    )
  );

  Widget buildModelText() => Text(
    aiController.model?.split('/').last ?? 'No model loaded',
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
      Switch(
        value: (aiController as OllamaNotifier).searchLocalNetwork ?? false,
        onChanged: (value) => onLocalSearchChanged(context, value),
      ),
    ],
  );

  void onLocalSearchChanged(BuildContext context, bool value) {
    if (
      (Platform.isAndroid || Platform.isIOS) &&
      (aiController as OllamaNotifier).searchLocalNetwork == null && 
      value
    ) {
      // Show alert dialog informing the user of the permissions required
      showDialog(
        context: context,
        builder: buildPermissionsAlert,
      );
      return;
    }

    (aiController as OllamaNotifier).searchLocalNetwork = value;
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

    (aiController as OllamaNotifier).searchLocalNetwork = true;
  }
}