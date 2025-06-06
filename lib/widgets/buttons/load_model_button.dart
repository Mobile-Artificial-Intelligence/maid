part of 'package:maid/main.dart';

class LoadModelButton extends StatelessWidget {
  final double popoverMinWidth = 150;
  final double popoverMaxWidth = 300;
  final GlobalKey buttonKey = GlobalKey();
  
  LoadModelButton({super.key});

  void onTap(BuildContext context) async {
    final List<PopupMenuEntry> popoverItems = [
      PopupMenuItem(
        value: 'load',
        child: Center(
          child: Text(AppLocalizations.of(context)!.loadModel),
        )
      ),
      PopupMenuItem(
        value: 'download',
        child: Center(
          child: Text(AppLocalizations.of(context)!.downloadModel),
        )
      ),
    ];

    if (LlamaCppController.instance!.modelOptions.isNotEmpty) {
      popoverItems.add(
        const PopupMenuDivider(),
      );

      for (final option in LlamaCppController.instance!.modelOptions) {
        popoverItems.add(
          PopupMenuItem(
            value: option,
            child: Center(
              child: Text(option.split('/').last),
            )
          ),
        );
      }
    }

    final selection = await showMenu(
      context: context,
      positionBuilder: popoverPositionBuilder,
      items: popoverItems,
      constraints: BoxConstraints(
        maxWidth: popoverMaxWidth,
        minWidth: popoverMinWidth,
      ),
    );

    if (selection == 'load') {
      LlamaCppController.instance!.pickModel();
    } 
    else if (selection == 'download' && context.mounted) {
      Navigator.of(context).pushNamed('/huggingface');
    }
    else if (selection != null && LlamaCppController.instance!.modelOptions.isNotEmpty) {
      LlamaCppController.instance!.loadModelFile(selection, true);
    }
  }

  RelativeRect popoverPositionBuilder(BuildContext context, BoxConstraints constraints) {
    // get the inkwell size using the key
    final RenderBox renderBox = buttonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    final width = LlamaCppController.instance!.modelOptions.isNotEmpty
      ? popoverMaxWidth
      : popoverMinWidth;

    return RelativeRect.fromLTRB(
      offset.dx + (size.width / 2) - (width / 2),
      offset.dy + size.height,
      offset.dx + (size.width / 2) + (width / 2),
      offset.dy,
    );
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
    key: buttonKey,
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
          listenable: LlamaCppController.instance!, 
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

    if (LlamaCppController.instance!.loading) {
      text = AppLocalizations.of(context)!.loading;
    }
    else {
      text = LlamaCppController.instance!.model != null ? 
        LlamaCppController.instance!.model!.split('/').last : 
        AppLocalizations.of(context)!.loadModel;
    }
    
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: buildStyle(context),
    );
  }
}