part of 'package:maid/main.dart';

class ChatTile extends StatefulWidget {
  final ChatController chatController;
  final ArtificialIntelligenceController aiController;
  final GeneralTreeNode<ChatMessage> node;
  final bool selected;

  const ChatTile({
    super.key,
    required this.chatController,
    required this.node,
    required this.selected,
    required this.aiController,
  });

  @override
  State<ChatTile> createState() => ChatTileState();
}

class ChatTileState extends State<ChatTile> {
  final GlobalKey key = GlobalKey();

  void onChatChange() {
    widget.chatController.root = widget.node;

    if (widget.aiController is LlamaCppController) {
      (widget.aiController as LlamaCppController).reloadModel(true);
    }
  }

  @override
  Widget build(BuildContext context) => InkWell(
    key: key,
    onTap: !widget.aiController.busy ? onChatChange : null,
    onSecondaryTap: openPopover, 
    onLongPress: openPopover,
    child: buildTile(),
  );
  
  Widget buildTile() => Container(
    padding: const EdgeInsets.all(16),
    child: Text(
      widget.node.currentChild?.data.content ?? widget.node.data.content,
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
    onTap:() => widget.chatController.deleteChat(widget.node),
  );

  PopupMenuItem buildExportPopover() => PopupMenuItem(
    child: Text(AppLocalizations.of(context)!.export),
    onTap:() => widget.chatController.exportChat(widget.node),
  );
}