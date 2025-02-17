part of 'package:maid/main.dart';

class ChatTile extends StatefulWidget {
  final GeneralTreeNode<ChatMessage> node;
  final bool selected;

  const ChatTile({
    super.key,
    required this.node,
    required this.selected,
  });

  @override
  State<ChatTile> createState() => ChatTileState();
}

class ChatTileState extends State<ChatTile> {
  void onChatChange() {
    ArtificialIntelligence.of(context).root = widget.node;
  }

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(
      widget.node.currentChild?.data.content ?? widget.node.data.content,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    ),
    selected: widget.selected,
    onTap: !ArtificialIntelligence.of(context).busy ? onChatChange : null,
  );
}