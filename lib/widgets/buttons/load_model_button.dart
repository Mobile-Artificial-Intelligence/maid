part of 'package:maid/main.dart';

class LoadModelButton extends StatelessWidget {
  const LoadModelButton({super.key});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 400),
    child: Material(
      color: Theme.of(context).colorScheme.primary,
      borderRadius: BorderRadius.circular(10),
      child: buildInkWell(context),
    ),
  );

  Widget buildInkWell(BuildContext context) => InkWell(
    onTap: ArtificialIntelligenceProvider.of(context).llamaCppNotifier!.pickModel,
    borderRadius: BorderRadius.circular(10),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: buildRow(context),
    )
  );

  TextStyle buildStyle(BuildContext context) => TextStyle(
    color: Theme.of(context).colorScheme.onPrimary,
    fontSize: 14,
  );

  Widget buildRow(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        "< < <",
        style: buildStyle(context),
      ),
      Expanded(
        child: Selector<ArtificialIntelligenceProvider, ({String? model, bool loading})>(selector: (context, ai) => (model: ai.model, loading: ai.llamaCppNotifier!.loading), builder: textBuilder),
      ),
      Text(
        "> > >",
        style: buildStyle(context),
      ),
    ],
  );

  Widget textBuilder(BuildContext context, ({String? model, bool loading}) record, Widget? child) {
    String text;

    if (record.loading) {
      text = "Loading...";
    }
    else {
      text = record.model != null ? record.model!.split('/').last : "Load Model";
    }
    
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: buildStyle(context),
    );
  }
}