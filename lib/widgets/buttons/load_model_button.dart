part of 'package:maid/main.dart';

class LoadModelButton extends StatelessWidget {
  final LlamaCppController llama;
  
  const LoadModelButton({super.key, required this.llama});

  void onTap(BuildContext context) async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    final RelativeRect position = RelativeRect.fromLTRB(
      offset.dx,
      offset.dy + size.height,
      offset.dx + size.width,
      offset.dy,
    );

    final selection = await showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          value: 'load',
          child: Text(AppLocalizations.of(context)!.loadModel),
        ),
        PopupMenuItem(
          value: 'download',
          child: Text(AppLocalizations.of(context)!.downloadModel),
        ),
      ],
    );

    if (selection == 'load') {
      llama.pickModel();
    } 
    else if (selection == 'download' && context.mounted) {
      Navigator.of(context).pushNamed('/huggingface');
    }
  }

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
    onTap: () => onTap(context),
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
      text = AppLocalizations.of(context)!.loading;
    }
    else {
      text = llama.model != null ? llama.model!.split('/').last : AppLocalizations.of(context)!.loadModel;
    }
    
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: buildStyle(context),
    );
  }
}