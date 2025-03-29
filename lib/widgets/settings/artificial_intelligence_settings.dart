part of 'package:maid/main.dart';

class ArtificialIntelligenceSettings extends StatelessWidget {
  final ArtificialIntelligenceController aiController;
  
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
        AppLocalizations.of(context)!.aiSettings(aiController.getTypeLocale(context)),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      aiController is RemoteArtificialIntelligenceController
        ? buildRemoteSettings(context)
        : LoadModelButton(llama: aiController as LlamaCppController),
    ],
  );

  Widget buildRemoteSettings(BuildContext context) => Column(
    children: [
      if (aiController is OllamaController && !kIsWeb) buildLocalSearchSwitchRow(context),
      const SizedBox(height: 8),
      RemoteModelTextField(aiController: aiController as RemoteArtificialIntelligenceController),
      const SizedBox(height: 8),
      BaseUrlTextField(aiController: aiController as RemoteArtificialIntelligenceController),
      const SizedBox(height: 8),
      ApiKeyTextField(aiController: aiController as RemoteArtificialIntelligenceController),
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
        value: (aiController as OllamaController).searchLocalNetwork ?? false,
        onChanged: (value) => onLocalSearchChanged(context, value),
      ),
    ],
  );

  void onLocalSearchChanged(BuildContext context, bool value) {
    if (
      TargetPlatformExtension.isMobile &&
      (aiController as OllamaController).searchLocalNetwork == null && 
      value
    ) {
      // Show alert dialog informing the user of the permissions required
      showDialog(
        context: context,
        builder: buildPermissionsAlert,
      );
      return;
    }

    (aiController as OllamaController).searchLocalNetwork = value;
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

    (aiController as OllamaController).searchLocalNetwork = true;
  }
}