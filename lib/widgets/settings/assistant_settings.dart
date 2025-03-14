part of 'package:maid/main.dart';

class AssistantSettings extends StatelessWidget {
  final AppSettings settings;
  
  const AssistantSettings({
    super.key, 
    required this.settings
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        AppLocalizations.of(context)!.assistantSettings,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      ListenableBuilder(
        listenable: settings,
        builder: assistantImageBuilder,
      ),
      const SizedBox(height: 8),
      ElevatedButton(
        onPressed: settings.loadAssistantImage, 
        child: Text(AppLocalizations.of(context)!.loadAssistantImage),
      ),
      const SizedBox(height: 8),
      ListenableTextField<AppSettings>(
        listenable: settings,
        selector: () => settings.assistantName,
        onChanged: settings.setAssistantName,
        labelText: AppLocalizations.of(context)!.assistantName,
      ),
    ],
  );

  Widget assistantImageBuilder(BuildContext context, Widget? child) {
    if (settings.assistantImage == null) {
      return Icon(
        Icons.assistant, 
        size: 50,
        color: Theme.of(context).colorScheme.onSurface
      );
    }

    return CircleAvatar(
      radius: 50,
      backgroundImage: MemoryImage(settings.assistantImage!),
    );
  }
}