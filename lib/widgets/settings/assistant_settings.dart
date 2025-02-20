part of 'package:maid/main.dart';

class AssistantSettings extends StatelessWidget {
  const AssistantSettings({super.key});

  @override
  Widget build(BuildContext context) => Column(
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
      SelectorTextField<AppSettings>(
        selector: (context, settings) => settings.assistantName,
        onChanged: AppSettings.of(context).setAssistantName,
        labelText: 'Assistant Name',
      ),
    ],
  );

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