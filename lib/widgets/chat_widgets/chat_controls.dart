import 'package:flutter/material.dart';
import 'package:maid/types/character.dart';
import 'package:maid/static/message_manager.dart';
import 'package:maid/types/model.dart';
import 'package:provider/provider.dart';

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
    int currentIndex = MessageManager.index(widget.key!);
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
              foregroundImage: Image.file(Provider.of<Character>(context, listen: false).profile).image,
              radius: 16,
            )
          ],
        if (siblingCount > 1)
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(0),
            width: 150,
            height: 30,
            decoration: BoxDecoration(
              color: MessageManager.busy 
                   ? Theme.of(context).colorScheme.primary 
                   : Theme.of(context).colorScheme.tertiary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: () {
                    if (MessageManager.busy) return;
                    MessageManager.last(widget.key!);
                    setState(() {});
                  },
                  icon: Icon(
                    Icons.arrow_left, 
                    color: Theme.of(context).colorScheme.onPrimary
                  )
                ),
                Text('$currentIndex/${siblingCount-1}', style: Theme.of(context).textTheme.labelLarge),
                IconButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: () {
                    if (MessageManager.busy) return;
                    MessageManager.next(widget.key!);
                    setState(() {});
                  },
                  icon: Icon(
                    Icons.arrow_right,
                    color: Theme.of(context).colorScheme.onPrimary),
                ),
              ],
            ),
          ),
        if (!widget.userGenerated)
          IconButton(
            padding: const EdgeInsets.all(0),
            onPressed: () {
              if (MessageManager.busy) return;
              MessageManager.regenerate(
                widget.key!, 
                Provider.of<Model>(context, listen: false), 
                Provider.of<Character>(context, listen: false)
              );
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
          ),
      ],
    );
  }
}
