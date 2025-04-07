part of 'package:maid/main.dart';

class SettingsPage extends StatelessWidget {
  final ArtificialIntelligenceController ai;
  final ChatController chatController;
  final AppSettings settings;
  
  const SettingsPage({
    super.key, 
    required this.ai, 
    required this.chatController,
    required this.settings
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(AppLocalizations.of(context)!.settingsTitle),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: buildBody(context),
    )
  );

  Widget buildBody(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.max,
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      ArtificialIntelligenceDropdown(ai: ai),
      ArtificialIntelligenceSettings(ai: ai),
      Divider(endIndent: 0, indent: 0, height: 32),
      ParameterView(ai: ai),
      Divider(endIndent: 0, indent: 0, height: 32),
      UserSettings(settings: settings),
      Divider(endIndent: 0, indent: 0, height: 32),
      AssistantSettings(settings: settings),
      Divider(endIndent: 0, indent: 0, height: 32),
      SystemSettings(settings: settings),
      Divider(endIndent: 0, indent: 0, height: 32),
      buildResetRow(context)
    ],
  );

  Widget buildResetRow(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    runAlignment: WrapAlignment.center,
    spacing: 16,
    runSpacing: 16,
    children: [
      ElevatedButton(
        onPressed: chatController.clear, 
        child: Text(AppLocalizations.of(context)!.clearChats)
      ),
      ElevatedButton(
        onPressed: settings.clear, 
        child: Text(AppLocalizations.of(context)!.resetSettings)
      ),
      ElevatedButton(
        onPressed: () {
          settings.clear();
          chatController.clear();
          ai.clear();
        }, 
        child: Text(AppLocalizations.of(context)!.clearCache)
      )
    ],
  );
}