part of 'package:maid/main.dart';

class ChatTile extends StatefulWidget {
  final ChatController chatController;
  final GeneralTreeNode<ChatMessage> node;
  final bool selected;
  final bool disabled;

  const ChatTile({
    super.key,
    required this.chatController,
    required this.node,
    required this.selected,
    required this.disabled,
  });

  @override
  State<ChatTile> createState() => ChatTileState();
}

class ChatTileState extends State<ChatTile> {
  final GlobalKey key = GlobalKey();

  void onChatChange() {
    widget.chatController.root = widget.node;
  }

  @override
  Widget build(BuildContext context) => ListTile(
    key: key,
    title: Text(
      widget.node.currentChild?.data.content ?? widget.node.data.content,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    ),
    selected: widget.selected,
    onTap: !widget.disabled ? onChatChange : null,
    onLongPress: openPopover,
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
      ],
    );
  }

  PopupMenuItem buildDeletePopover() => PopupMenuItem(
    child: Text(AppLocalizations.of(context)!.delete),
    onTap:() => widget.chatController.deleteChat(widget.node),
  );
}