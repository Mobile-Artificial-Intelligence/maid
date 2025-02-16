part of 'package:maid/main.dart';

class LlamaSettings extends StatelessWidget {
  const LlamaSettings({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        'Llama Settings',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: buildModelLoader(context),
      )
    ],
  );

  Widget buildModelLoader(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      buildTitle(),
      IconButton(onPressed: ArtificialIntelligence.of(context).loadModel, icon: const Icon(Icons.folder)),
    ],
  );

  Widget buildTitle() => Expanded(
    child: Selector<ArtificialIntelligence, File?>(
      selector: (context, ai) => ai.model,
      builder: buildTitleText,
    ),
  );

  Widget buildTitleText(BuildContext context, File? model, Widget? child) => Text(
    model?.path.split('/').last ?? 'No model loaded',
    overflow: TextOverflow.ellipsis,
    maxLines: 1,
  );
}