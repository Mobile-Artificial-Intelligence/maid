import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maid/config/chat_node.dart';
import 'package:maid/config/settings.dart';

class ChatMessage extends StatefulWidget {
  final bool userGenerated;

  const ChatMessage({
    required UniqueKey super.key, 
    this.userGenerated = false, 
  });

  @override
  ChatMessageState createState() => ChatMessageState();
}

class ChatMessageState extends State<ChatMessage> with SingleTickerProviderStateMixin {
  final List<Widget> _messageWidgets = [];
  Offset _tapPosition = Offset.zero;
  String _message = "";
  bool _finalised = false;

  @override
  void initState() {
    super.initState();

    if (MessageManager.get(widget.key!).isNotEmpty) {
      _parseMessage(MessageManager.get(widget.key!));
      _finalised = true;
    } else {
      MessageManager.getMessageStream(widget.key!).stream.listen((textChunk) {
        print("Stream: $textChunk");
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

  void _showContextMenu() {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        _tapPosition & const Size(40, 40), // Using size & position of longPress/rightClick on the screen
        Offset.zero & overlay.size,
      ),
      items: [
        const PopupMenuItem(
          value: 'edit',
          child: Text('Edit'),
        ),
      ],
    ).then((selectedValue) {
      if (selectedValue == 'edit') {
        _editMessage();
      }
    });
  }
  
  void _editMessage() {
    // Your logic to edit the message goes here.
    print('Editing the message');
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.userGenerated ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTapDown: (details) {
          _tapPosition = details.globalPosition;
          _showContextMenu();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: widget.userGenerated
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: !_finalised && _messageWidgets.isEmpty
            ? const TypingIndicator()
            : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _messageWidgets,
          ),
        ),
      )
    );
  }

  @override
  void dispose() {
    MessageManager.getMessageStream(widget.key!).close();
    MessageManager.getFinaliseStream(widget.key!).close();
    super.dispose();
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  TypingIndicatorState createState() => TypingIndicatorState();
}

class TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _repeatingController;
  final List<Interval> _dotIntervals = const [
    Interval(0.25, 0.8),
    Interval(0.35, 0.9),
    Interval(0.45, 1.0),
  ];

  @override
  void initState() {
    super.initState();
    _repeatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          _dotIntervals.length,
          (index) => AnimatedBuilder(
            animation: _repeatingController,
            builder: (context, child) {
              final circleFlashPercent =
                  _dotIntervals[index].transform(_repeatingController.value);
              final circleColorPercent = sin(pi * circleFlashPercent);
              return Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.lerp(
                    Theme.of(context).colorScheme.background,
                    Theme.of(context).colorScheme.secondary,
                    circleColorPercent,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _repeatingController.dispose();
    super.dispose();
  }
}

class CodeBox extends StatelessWidget {
  final String code;

  const CodeBox({Key? key, required this.code}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(5),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,  // Allow horizontal scrolling
              child: Row(
                children: [
                  SelectableText(
                    code,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.copy, color: Theme.of(context).colorScheme.secondary),
          onPressed: () async {
            final ctx = context;
            Clipboard.setData(ClipboardData(text: code)).then((_) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text("Code copied to clipboard!")),
              );
            });
          },
          tooltip: 'Copy Code',
        ),
      ],
    );
  }
}
