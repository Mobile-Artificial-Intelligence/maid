part of 'package:maid/main.dart';

class OpenAiSettings extends StatelessWidget {
  const OpenAiSettings({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Divider(endIndent: 0, indent: 0, height: 32),
      Text(
        'Open AI Settings',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      buildRemoteModel(context),
      const SizedBox(height: 8),
      BaseUrlTextField(ecosystem: LlmEcosystem.openAI),
      const SizedBox(height: 8),
      ApiKeyTextField(ecosystem: LlmEcosystem.openAI),
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
        ecosystem: LlmEcosystem.openAI,
        refreshButton: true,
      ),
    ],
  );
}