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
      LlmEcosystemDropdown(),
      buildEcosystemSettings(),
      Divider(endIndent: 0, indent: 0, height: 32),
      OverrideView(),
      Divider(endIndent: 0, indent: 0, height: 32),
      buildUserSettings(context),
      Divider(endIndent: 0, indent: 0, height: 32),
      buildAssistantSettings(context),
      Divider(endIndent: 0, indent: 0, height: 32),
      buildSystemSettings(context),
      Divider(endIndent: 0, indent: 0, height: 32),
      buildResetRow(context)
    ],
  );

  Widget buildEcosystemSettings() => Selector<ArtificialIntelligence, LlmEcosystem>(
    selector: (context, ai) => ai.ecosystem,
    builder: ecosystemSettingsBuilder
  );

  Widget ecosystemSettingsBuilder(BuildContext context, LlmEcosystem ecosystem, Widget? child) {
    switch (ecosystem) {
      case LlmEcosystem.ollama:
        return const OllamaSettings();
      case LlmEcosystem.llamaCPP:
        return const LlamaCppSettings();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget buildResetRow(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      ElevatedButton(
        onPressed: ArtificialIntelligence.of(context).clearChats, 
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

  Widget buildSystemSettings(BuildContext context) => Column(
    children: [
      Text(
        'System Settings',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      TextField(
        decoration: const InputDecoration(
          labelText: 'System Prompt',
        ),
        controller: TextEditingController(
          text: AppSettings.of(context).systemPrompt
        ),
        onChanged: AppSettings.of(context).setSystemPrompt,
        keyboardType: TextInputType.multiline,
        maxLines: null
      ),
      const SizedBox(height: 8),
      ThemeModeDropdown(),
      const SizedBox(height: 8),
      Text(
        'Theme Seed Color',
        style: Theme.of(context).textTheme.labelLarge,
      ),
      const SizedBox(height: 4),
      buildColorPicker(),
    ],
  );

  Widget buildColorPicker() => Selector<AppSettings, Color>(
    selector: (context, settings) => settings.seedColor,
    builder: (context, color, child) => ColorPicker(
      pickerColor: color, 
      onColorChanged: (newColor) => AppSettings.of(context).seedColor = newColor,
    ),
  );

  Widget buildUserSettings(BuildContext context) => Column(
    children: [
      Text(
        'User Settings',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      Selector<AppSettings, File?>(
        selector: (context, settings) => settings.userImage,
        builder: userImageBuilder,
      ),
      const SizedBox(height: 8),
      ElevatedButton(
        onPressed: AppSettings.of(context).loadUserImage, 
        child: const Text('Load User Image')
      ),
      const SizedBox(height: 8),
      TextField(
        decoration: const InputDecoration(
          labelText: 'User Name',
        ),
        controller: TextEditingController(
          text: AppSettings.of(context).userName
        ),
        onChanged: AppSettings.of(context).setUserName,
      ),
    ],
  );

  Widget buildAssistantSettings(BuildContext context) => Column(
    children: [
      Text(
        'Assistant Settings',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      Selector<AppSettings, File?>(
        selector: (context, settings) => settings.assistantImage,
        builder: assistantImageBuilder,
      ),
      const SizedBox(height: 8),
      ElevatedButton(
        onPressed: AppSettings.of(context).loadAssistantImage, 
        child: const Text('Load Assistant Image'),
      ),
      const SizedBox(height: 8),
      TextField(
        decoration: const InputDecoration(
          labelText: 'Assistant Name',
        ),
        controller: TextEditingController(
          text: AppSettings.of(context).assistantName
        ),
        onChanged: AppSettings.of(context).setAssistantName,
      ),
    ],
  );

  Widget userImageBuilder(BuildContext context, File? image, Widget? child) {
    if (image == null) {
      return Icon(
        Icons.person, 
        size: 50,
        color: Theme.of(context).colorScheme.onSurface
      );
    }

    return CircleAvatar(
      radius: 50,
      backgroundImage: FileImage(image),
    );
  }

  Widget assistantImageBuilder(BuildContext context, File? image, Widget? child) {
    if (image == null) {
      return Icon(
        Icons.assistant, 
        size: 50,
        color: Theme.of(context).colorScheme.onSurface
      );
    }

    return CircleAvatar(
      radius: 50,
      backgroundImage: FileImage(image),
    );
  }
}