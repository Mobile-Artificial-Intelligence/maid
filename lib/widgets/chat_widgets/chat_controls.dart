import 'package:flutter/material.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/static/generation_manager.dart';
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
    return Consumer<Session>(
      builder: (context, session, child) {
        int currentIndex = session.index(widget.key!);
        int siblingCount = session.siblingCount(widget.key!);

        return Row(
          mainAxisAlignment: widget.userGenerated
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
          children: [
            if (widget.userGenerated)
              IconButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  if (GenerationManager.busy) return;
                  session.branch(widget.key!, widget.userGenerated);
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
                  color: GenerationManager.busy 
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
                        if (GenerationManager.busy) return;
                        session.last(widget.key!);
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
                        if (GenerationManager.busy) return;
                        session.next(widget.key!);
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
                  if (GenerationManager.busy) return;
                  session.regenerate(
                    widget.key!,
                    context
                  );
                  setState(() {});
                },
                icon: const Icon(Icons.refresh),
              ),
          ],
        );
      },
    );
  }
}
