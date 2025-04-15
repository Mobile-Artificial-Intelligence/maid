part of 'package:maid/main.dart';

class ArtificialIntelligenceSettings extends StatelessWidget {
  const ArtificialIntelligenceSettings({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: AIController.instance,
    builder: buildColumn,
  );

  Widget buildColumn(BuildContext context, Widget? child) => Column(
    children: [
      Divider(endIndent: 0, indent: 0, height: 32),
      Text(
        AppLocalizations.of(context)!.aiSettings(AIController.instance.getTypeLocale(context)),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      RemoteAIController.instance != null
        ? buildRemoteSettings(context)
        : LoadModelButton(),
    ],
  );

  Widget buildRemoteSettings(BuildContext context) => Column(
    children: [
      if (OllamaController.instance != null && !kIsWeb) buildLocalSearchSwitchRow(context),
      const SizedBox(height: 8),
      RemoteModelTextField(),
      const SizedBox(height: 8),
      BaseUrlTextField(),
      const SizedBox(height: 8),
      ApiKeyTextField(),
    ]
  );

  Widget buildLocalSearchSwitchRow(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        AppLocalizations.of(context)!.searchLocalNetwork,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      Switch(
        value: OllamaController.instance!.searchLocalNetwork ?? false,
        onChanged: (value) => onLocalSearchChanged(context, value),
      ),
    ],
  );

  void onLocalSearchChanged(BuildContext context, bool value) {
    if (
      TargetPlatformExtension.isMobile &&
      OllamaController.instance!.searchLocalNetwork == null && 
      value
    ) {
      // Show alert dialog informing the user of the permissions required
      showDialog(
        context: context,
        builder: buildPermissionsAlert,
      );
      return;
    }

    OllamaController.instance!.searchLocalNetwork = value;
  }

  Widget buildPermissionsAlert(BuildContext context) => AlertDialog(
    title: Text(
      AppLocalizations.of(context)!.localNetworkSearchTitle,
      textAlign: TextAlign.center,
    ),
    content: Text(
      AppLocalizations.of(context)!.localNetworkSearchContent,
      textAlign: TextAlign.center,
    ),
    actionsAlignment: MainAxisAlignment.spaceEvenly,
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(AppLocalizations.of(context)!.cancel),
      ),
      TextButton(
        onPressed: () => closePermissionsAlert(context),
        child: Text(AppLocalizations.of(context)!.ok),
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

    OllamaController.instance!.searchLocalNetwork = true;
  }
}