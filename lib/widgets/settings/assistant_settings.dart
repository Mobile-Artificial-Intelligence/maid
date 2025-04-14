part of 'package:maid/main.dart';

class AssistantSettings extends StatelessWidget {
  const AssistantSettings({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        AppLocalizations.of(context)!.assistantSettings,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      ListenableBuilder(
        listenable: AppSettings.instance,
        builder: assistantImageBuilder,
      ),
      const SizedBox(height: 8),
      ElevatedButton(
        onPressed: AppSettings.instance.loadAssistantImage, 
        child: Text(AppLocalizations.of(context)!.loadAssistantImage),
      ),
      const SizedBox(height: 8),
      ListenableTextField<AppSettings>(
        listenable: AppSettings.instance,
        selector: () => AppSettings.instance.assistantName,
        onChanged: AppSettings.instance.setAssistantName,
        labelText: AppLocalizations.of(context)!.assistantName,
      ),
    ],
  );

  Widget assistantImageBuilder(BuildContext context, Widget? child) {
    if (AppSettings.instance.assistantImage == null) {
      return Icon(
        Icons.assistant, 
        size: 50,
        color: Theme.of(context).colorScheme.onSurface
      );
    }

    return CircleAvatar(
      radius: 50,
      backgroundImage: MemoryImage(AppSettings.instance.assistantImage!),
    );
  }
}