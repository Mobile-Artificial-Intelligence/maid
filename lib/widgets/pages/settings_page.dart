part of 'package:maid/main.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
      ArtificialIntelligenceDropdown(),
      ArtificialIntelligenceSettings(),
      Divider(endIndent: 0, indent: 0, height: 32),
      ParameterView(),
      Divider(endIndent: 0, indent: 0, height: 32),
      UserSettings(),
      Divider(endIndent: 0, indent: 0, height: 32),
      AssistantSettings(),
      Divider(endIndent: 0, indent: 0, height: 32),
      SystemSettings(),
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
        onPressed: ChatController.instance.clear, 
        child: Text(AppLocalizations.of(context)!.clearChats)
      ),
      ElevatedButton(
        onPressed: AppSettings.instance.clear, 
        child: Text(AppLocalizations.of(context)!.resetSettings)
      ),
      ElevatedButton(
        onPressed: () {
          AppSettings.instance.clear();
          ChatController.instance.clear();
          ArtificialIntelligenceController.instance.clear();
        }, 
        child: Text(AppLocalizations.of(context)!.clearCache)
      )
    ],
  );
}