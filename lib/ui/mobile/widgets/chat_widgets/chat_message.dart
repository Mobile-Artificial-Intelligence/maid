import 'package:flutter/material.dart';
import 'package:maid_llm/maid_llm.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/providers/user.dart';

import 'package:maid_ui/maid_ui.dart';
import 'package:provider/provider.dart';

class ChatMessage extends StatefulWidget {
  final ChatNode node;

  const ChatMessage({
    super.key,
    required this.node,
  });

  @override
  ChatMessageState createState() => ChatMessageState();
}

class ChatMessageState extends State<ChatMessage> with SingleTickerProviderStateMixin {
  bool _editing = false;

  Widget _messageBuilder(String message) {
    List<Widget> widgets = [];
    List<String> parts = message.split('```');

    for (int i = 0; i < parts.length; i++) {
      String part = parts[i].trim();
      if (part.isEmpty) continue;

      if (i % 2 == 0) {
        widgets.add(SelectableText(part, style: TextStyle(
              fontWeight: FontWeight.normal,
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 16,
            )
          )
        );
      } else {
        widgets.addAll([
          const SizedBox(height: 10),
          CodeBox(code: part), // Assuming CodeBox is a widget you've defined for displaying code.
          const SizedBox(height: 10),
        ]);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<Session, User, Character>(
      builder: (context, session, user, character, child) {
        int currentIndex = session.chat.indexOf(widget.node.key);
        int siblingCount = session.chat.siblingCountOf(widget.node.key);

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 10.0),
              FutureAvatar(
                image: widget.node.role == ChatRole.user ? user.profile : character.profile,
                radius: 16,
              ),
              const SizedBox(width: 10.0),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 0, 200, 255),
                    Color.fromARGB(255, 255, 80, 200)
                  ],
                  stops: [0.5, 0.85],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                blendMode: BlendMode
                    .srcIn, // This blend mode applies the shader to the text color.
                child: Text(
                  widget.node.role == ChatRole.user ? user.name : character.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors
                        .white, // This color is needed, but it will be overridden by the shader.
                    fontSize: 20,
                  ),
                ),
              ),
              const Expanded(child: SizedBox()), // Spacer
              if (widget.node.finalised) ..._messageOptions(),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: () {
                        if (!session.chat.tail.finalised) return;
                        session.chat.last(widget.node.key);
                        session.notify();
                      },
                      icon: Icon(Icons.arrow_left,
                          color: Theme.of(context).colorScheme.onPrimary)),
                  Text('${currentIndex + 1}/$siblingCount',
                      style: Theme.of(context).textTheme.labelLarge),
                  IconButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: () {
                      if (!session.chat.tail.finalised) return;
                      session.chat.next(widget.node.key);
                      session.notify();
                    },
                    icon: Icon(Icons.arrow_right,
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ],
              )
            ],
          ),
          Padding(
              // left padding 30 right 10
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _editing ? _editingColumn() : _standardColumn(),
              ))
        ]);
      },
    );
  }

  List<Widget> _messageOptions() {
    return widget.node.role == ChatRole.user ? _userOptions() : _assistantOptions();
  }

  List<Widget> _userOptions() {
    return [
      IconButton(
        onPressed: () {
          if (!context.read<Session>().chat.tail.finalised) return;
          setState(() {
            _editing = true;
          });
        },
        icon: const Icon(Icons.edit),
      ),
    ];
  }

  List<Widget> _assistantOptions() {
    return [
      IconButton(
        onPressed: () {
          if (!context.read<Session>().chat.tail.finalised) return;
          context.read<Session>().regenerate(widget.node.key, context);
          setState(() {});
        },
        icon: const Icon(Icons.refresh),
      ),
    ];
  }

  List<Widget> _editingColumn() {
    final messageController = TextEditingController(text: widget.node.content);

    return [
      TextField(
        controller: messageController,
        autofocus: true,
        cursorColor: Theme.of(context).colorScheme.secondary,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: "Edit Message",
          fillColor: Theme.of(context).colorScheme.background,
          contentPadding: EdgeInsets.zero,
        ),
        maxLines: null,
        keyboardType: TextInputType.multiline,
      ),
      Row(children: [
        IconButton(
            padding: const EdgeInsets.all(0),
            onPressed: () {
              if (!context.watch<Session>().chat.tail.finalised) return;
              setState(() {
                _editing = false;
              });
              context.read<Session>().edit(widget.node.key, messageController.text, context);
            },
            icon: const Icon(Icons.done)),
        IconButton(
            padding: const EdgeInsets.all(0),
            onPressed: () {
              setState(() {
                _editing = false;
              });
            },
            icon: const Icon(Icons.close))
      ])
    ];
  }

  List<Widget> _standardColumn() {
    return [
      if (!widget.node.finalised && widget.node.content.isEmpty)
        const TypingIndicator() // Assuming TypingIndicator is a custom widget you've defined.
      else
        _messageBuilder(widget.node.content),
    ];
  }
}
