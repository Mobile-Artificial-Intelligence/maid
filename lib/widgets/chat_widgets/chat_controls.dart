import 'package:flutter/material.dart';
import 'package:maid/types/character.dart';
import 'package:maid/static/message_manager.dart';
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
              if (MessageManager.busy) return;
		          MessageManager.promptController.text = MessageManager.get(widget.key!);
              MessageManager.promptFocusNode.requestFocus(); 
              MessageManager.branch(widget.key!, widget.userGenerated);
              setState(() {});
            },
            icon: const Icon(Icons.edit),
          )
        else
          ...[
            const SizedBox(width: 10.0),
            CircleAvatar(
              backgroundImage: const AssetImage("assets/default_profile.png"),
              foregroundImage: Image.file(character.profile).image,
              radius: 16,
            )
          ],
        if (siblingCount > 1)
          BranchSwitcher(key: widget.key!),
        if (!widget.userGenerated)
          IconButton(
            padding: const EdgeInsets.all(0),
            onPressed: () {
              if (MessageManager.busy) return;
              MessageManager.regenerate(widget.key!);
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
          ),
      ],
    );
  }
}
