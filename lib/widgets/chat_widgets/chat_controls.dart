import 'package:flutter/material.dart';
import 'package:maid/utilities/message_manager.dart';
import 'package:maid/widgets/chat_widgets/branch_switcher.dart';

class ChatControls extends StatefulWidget {
  final bool userGenerated;
  
  const ChatControls({
    required super.key, 
    this.userGenerated = false, 
  });

  @override
  ChatControlsState createState() => ChatControlsState();
}

class ChatControlsState extends State<ChatControls> {
  @override
  Widget build(BuildContext context) {
    int siblingCount = MessageManager.siblingCount(widget.key!);

    return Row(
      mainAxisAlignment: widget.userGenerated
        ? MainAxisAlignment.end
        : MainAxisAlignment.start,
      children: [
        if (widget.userGenerated)
          IconButton(
            padding: const EdgeInsets.all(0),
            onPressed: () {
              MessageManager.branch(widget.key!, widget.userGenerated);
              setState(() {});
            },
            icon: const Icon(Icons.edit),
          ),
        if (siblingCount > 1)
          BranchSwitcher(key: widget.key!),
        if (!widget.userGenerated)
          IconButton(
            padding: const EdgeInsets.all(0),
            onPressed: () {
              MessageManager.regenerate(widget.key!);
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
          ),
      ],
    );
  }
}