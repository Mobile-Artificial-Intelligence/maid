part of 'package:maid/main.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Settings'),
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
      EcosystemDropdown(),
      ArtificialIntelligenceSettings(),
      Divider(endIndent: 0, indent: 0, height: 32),
      OverrideView(),
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
        onPressed: MaidContext.of(context).clearChats, 
        child: const Text('Clear Chats')
      ),
      ElevatedButton(
        onPressed: AppSettings.of(context).clear, 
        child: const Text('Reset Settings')
      ),
      ElevatedButton(
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
        }, 
        child: const Text('Clear Cache')
      )
    ],
  );
}