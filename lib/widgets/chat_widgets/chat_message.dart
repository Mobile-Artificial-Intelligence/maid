import 'package:flutter/material.dart';
import 'package:maid/utilities/message_manager.dart';

import 'package:maid/widgets/chat_widgets/code_box.dart';
import 'package:maid/widgets/chat_widgets/typing_indicator.dart';
import 'package:maid/widgets/chat_widgets/chat_controls.dart';

class ChatMessage extends StatefulWidget {
  final bool userGenerated;

  const ChatMessage({
    required super.key, 
    this.userGenerated = false, 
  });

  @override
  ChatMessageState createState() => ChatMessageState();
}

class ChatMessageState extends State<ChatMessage> with SingleTickerProviderStateMixin {
  final List<Widget> _messageWidgets = [];
  String _message = "";
  bool _finalised = false;

  @override
  void initState() {
    super.initState();

    if (MessageManager.get(widget.key!).isNotEmpty) {
      _parseMessage(MessageManager.get(widget.key!));
    } else {
      MessageManager.getMessageStream(widget.key!).stream.listen((textChunk) {
        setState(() {
          _message += textChunk;
          _messageWidgets.clear();
          _parseMessage(_message);
        });
      });

      MessageManager.getFinaliseStream(widget.key!).stream.listen((_) {
        setState(() {
          _message = _message.trim();
          _parseMessage(_message);
          MessageManager.add(widget.key!, message: _message, userGenerated: widget.userGenerated);
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
        _messageWidgets.add(CodeBox(code: part));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ChatControls(key: widget.key, userGenerated: widget.userGenerated),
        Align(
          alignment: widget.userGenerated ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.userGenerated
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_finalised && _messageWidgets.isEmpty)
                  const TypingIndicator()
                else
                  ..._messageWidgets,
              ],
            )
          ),
        )
      ]
    );
  }

  @override
  void dispose() {
    MessageManager.getMessageStream(widget.key!).close();
    MessageManager.getFinaliseStream(widget.key!).close();
    super.dispose();
  }
}