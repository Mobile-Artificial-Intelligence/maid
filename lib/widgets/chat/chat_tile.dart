part of 'package:maid/main.dart';

class ChatTile extends StatefulWidget {
  final ArtificialIntelligenceController ai;
  final ChatMessage node;
  final bool selected;

  const ChatTile({
    super.key,
    required this.node,
    required this.selected,
    required this.ai,
  });

  @override
  State<ChatTile> createState() => ChatTileState();
}

class ChatTileState extends State<ChatTile> {
  final GlobalKey key = GlobalKey();

  void onChatChange() {
    ChatController.instance.root = widget.node;

    if (widget.ai is LlamaCppController) {
      (widget.ai as LlamaCppController).reloadModel(true);
    }
  }

  @override
  Widget build(BuildContext context) => InkWell(
    key: key,
    onTap: !widget.ai.busy ? onChatChange : null,
    onSecondaryTap: openPopover, 
    onLongPress: openPopover,
    child: buildTile(),
  );
  
  Widget buildTile() => Container(
    padding: const EdgeInsets.all(16),
    child: Text(
      widget.node.currentChild?.content ?? widget.node.content,
      style: TextStyle(
        color: widget.selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
        fontSize: 16,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    ),
  );

  void openPopover() {
    final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final double tileWidth = renderBox.size.width;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx + tileWidth + 10,
        offset.dy, 
        offset.dx + tileWidth + 210,
        offset.dy + renderBox.size.height,
      ),
      items: [
        buildDeletePopover(),
        buildExportPopover(),
      ],
    );
  }

  PopupMenuItem buildDeletePopover() => PopupMenuItem(
    child: Text(AppLocalizations.of(context)!.delete),
    onTap:() => ChatController.instance.deleteChat(widget.node),
  );

  PopupMenuItem buildExportPopover() => PopupMenuItem(
    child: Text(AppLocalizations.of(context)!.export),
    onTap:() => ChatController.instance.exportChat(widget.node),
  );
}