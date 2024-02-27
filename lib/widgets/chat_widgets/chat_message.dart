import 'package:flutter/material.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/static/user.dart';

import 'package:maid_ui/maid_ui.dart';
import 'package:provider/provider.dart';

class ChatMessage extends StatefulWidget {
  final bool userGenerated;

  const ChatMessage({
    required super.key,
    this.userGenerated = false,
  });

  @override
  ChatMessageState createState() => ChatMessageState();
}

class ChatMessageState extends State<ChatMessage>
    with SingleTickerProviderStateMixin {
  final List<Widget> _messageWidgets = [];
  late Session session;
  final TextEditingController _messageController = TextEditingController();
  String _message = "";
  bool _finalised = false;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    session = context.read<Session>();

    if (session.getMessage(widget.key!).isNotEmpty) {
      _message = session.getMessage(widget.key!);
      _parseMessage(_message);
      _finalised = true;
    } else {
      session.getMessageStream(widget.key!).stream.listen((textChunk) {
        setState(() {
          _message += textChunk;
          _messageWidgets.clear();
          _parseMessage(_message);
        });
      });

      session.getFinaliseStream(widget.key!).stream.listen((_) {
        setState(() {
          _message = _message.trim();
          _parseMessage(_message);
          session.add(widget.key!,
              message: _message, userGenerated: widget.userGenerated);
          _finalised = true;
        });
      });
    }
  }

  void _parseMessage(String message) {
    _messageWidgets.clear();
    List<String> parts = message.split('```');
    for (int i = 0; i < parts.length; i++) {
      String part = parts[i].trim();
      if (part.isEmpty) continue;

      if (i % 2 == 0) {
        _messageWidgets.add(SelectableText(part));
      } else {
        _messageWidgets.addAll([
          const SizedBox(height: 10),
          CodeBox(code: part),
          const SizedBox(height: 10)
        ]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 10.0),
          CircleAvatar(
            backgroundImage: const AssetImage("assets/default_profile.png"),
            foregroundImage:
                Image.file(context.read<Character>().profile).image,
            radius: 16,
          ),
          const SizedBox(width: 10.0),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 172, 200),
                Color.fromARGB(255, 255, 150, 250),
                Color.fromARGB(255, 150, 240, 255)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            blendMode: BlendMode
                .srcIn, // This blend mode applies the shader to the text color.
            child: Text(
              widget.userGenerated ? User.name : context.read<Character>().name,
              style: const TextStyle(
                // The color must be white (or any color) to ensure the gradient is visible.
                color: Colors
                    .white, // This color is needed, but it will be overridden by the shader.
                fontSize: 20,
              ),
            ),
          ),
          const Expanded(child: SizedBox()), // Spacer
          if (_finalised) ..._messageOptions(),
          Consumer<Session>(
            builder: (context, session, child) {
              int currentIndex = session.index(widget.key!);
              int siblingCount = session.siblingCount(widget.key!);
              bool busy = session.isBusy;

              return Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: () {
                        if (busy) return;
                        session.last(widget.key!);
                      },
                      icon: Icon(Icons.arrow_left,
                          color: Theme.of(context).colorScheme.onPrimary)),
                  Text('${currentIndex + 1}/$siblingCount',
                      style: Theme.of(context).textTheme.labelLarge),
                  IconButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: () {
                      if (busy) return;
                      session.next(widget.key!);
                    },
                    icon: Icon(Icons.arrow_right,
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      Padding(
          // left padding 30 right 10
          padding: const EdgeInsets.fromLTRB(60, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _editing ? _editingColumn() : _standardColumn(),
          ))
    ]);
  }

  List<Widget> _messageOptions() {
    return widget.userGenerated ? _userOptions() : _assistantOptions();
  }

  List<Widget> _userOptions() {
    return [
      IconButton(
        onPressed: () {
          if (session.isBusy) return;
          setState(() {
            _messageController.text = _message;
            _editing = true;
            _finalised = false;
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
          if (session.isBusy) return;
          session.regenerate(widget.key!, context);
          setState(() {});
        },
        icon: const Icon(Icons.refresh),
      ),
    ];
  }

  List<Widget> _editingColumn() {
    final busy = context.watch<Session>().isBusy;

    return [
      TextField(
        controller: _messageController,
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
              if (busy) return;
              final inputMessage = _messageController.text;
              setState(() {
                _messageController.text = _message;
                _editing = false;
                _finalised = true;
              });
              session.edit(widget.key!, context, inputMessage);
            },
            icon: const Icon(Icons.done)),
        IconButton(
            padding: const EdgeInsets.all(0),
            onPressed: () {
              setState(() {
                _messageController.text = _message;
                _editing = false;
                _finalised = true;
              });
            },
            icon: const Icon(Icons.close))
      ])
    ];
  }

  List<Widget> _standardColumn() {
    return [
      if (!_finalised && _messageWidgets.isEmpty)
        const TypingIndicator()
      else
        ..._messageWidgets
    ];
  }

  @override
  void dispose() {
    session.getMessageStream(widget.key!).close();
    session.getFinaliseStream(widget.key!).close();
    super.dispose();
  }
}
