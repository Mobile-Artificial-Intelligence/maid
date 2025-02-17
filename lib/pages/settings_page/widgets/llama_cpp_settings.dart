part of 'package:maid/main.dart';

class LlamaCppSettings extends StatelessWidget {
  const LlamaCppSettings({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        'Llama Settings',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      buildRow(context)
    ],
  );

  Widget buildRow(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.max,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      buildTitle(),
      buildModelLoader(context),
    ],
  );

  Widget buildModelLoader(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      buildModelText(),
      IconButton(onPressed: ArtificialIntelligence.of(context).loadModel, icon: const Icon(Icons.folder)),
    ],
  );

  Widget buildTitle() => Expanded(
    child: Text(
      'Llama CPP Model',
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    )
  );

  Widget buildModelText() => Selector<ArtificialIntelligence, String?>(
    selector: (context, ai) => ai.llamaCppModel,
    builder: modelTextBuilder,
  );

  Widget modelTextBuilder(BuildContext context, String? model, Widget? child) => Text(
    model?.split('/').last ?? 'No model loaded',
    overflow: TextOverflow.ellipsis,
    maxLines: 1,
  );
}