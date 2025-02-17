part of 'package:maid/main.dart';

class OllamaSettings extends StatelessWidget {
  const OllamaSettings({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        'Ollama Settings',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      buildRemoteModel(context)
    ],
  );

  Widget buildRemoteModel(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      buildTitle(),
      RemoteModelDropdown(),
    ],
  );

  Widget buildTitle() => Text(
    'Remote Model',
    overflow: TextOverflow.ellipsis,
    maxLines: 1,
  );
}