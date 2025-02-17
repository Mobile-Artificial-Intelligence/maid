part of 'package:maid/main.dart';

class OllamaSettings extends StatelessWidget {
  const OllamaSettings({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Divider(endIndent: 0, indent: 0, height: 32),
      Text(
        'Ollama Settings',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      buildRemoteModel(context),
      const SizedBox(height: 8),
      buildLocalSearchSwitch(context),
    ],
  );

  Widget buildRemoteModel(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        'Remote Model',
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      RemoteModelDropdown(
        getModelOptions: ArtificialIntelligence.of(context).getOllamaModelOptions,
      ),
    ],
  );

  Widget buildLocalSearchSwitch(BuildContext context) => Row(
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

  Widget buildSwitch(BuildContext context, bool? searchLocalNetwork, Widget? child) => Switch(
    value: searchLocalNetwork ?? false,
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