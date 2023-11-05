import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maid/config/message_manager.dart';

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

  const CodeBox({super.key, required this.code});

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

class BranchSwitcher extends StatefulWidget {
  const BranchSwitcher({required super.key});

  @override
  BranchSwitcherState createState() => BranchSwitcherState();
}

class BranchSwitcherState extends State<BranchSwitcher> {
  @override
  Widget build(BuildContext context) {
    int currentIndex = MessageManager.index(widget.key!);
    int siblingCount = MessageManager.siblingCount(widget.key!);

    return SizedBox(
      width: 120,
      height: 40,
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  MessageManager.last(widget.key!);
                  setState(() {});
                },
                icon: const Icon(Icons.arrow_left),
              ),
              Text('$currentIndex/${siblingCount-1}'),
              IconButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  MessageManager.next(widget.key!);
                  setState(() {});
                },
                icon: const Icon(Icons.arrow_right),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
