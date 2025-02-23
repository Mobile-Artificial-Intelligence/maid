part of 'package:maid/main.dart';

class LoadModelButton extends StatelessWidget {
  final LlamaCppNotifier llama;
  
  const LoadModelButton({super.key, required this.llama});

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
    key: ValueKey("load_model"),
    onTap: llama.pickModel,
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
        child: ListenableBuilder(
          listenable: llama, 
          builder: textBuilder
        )
      ),
      Text(
        "> > >",
        style: buildStyle(context),
      ),
    ],
  );

  Widget textBuilder(BuildContext context, Widget? child) {
    String text;

    if (llama.loading) {
      text = "Loading...";
    }
    else {
      text = llama.model != null ? llama.model!.split('/').last : "Load Model";
    }
    
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: buildStyle(context),
    );
  }
}