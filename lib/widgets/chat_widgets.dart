import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maid/config/settings.dart';

class ChatMessage extends StatefulWidget {
  final StreamController<String> messageController =
      StreamController<String>.broadcast();
  final StreamController<int> trimController =
      StreamController<int>.broadcast();
  final StreamController<int> finaliseController =
      StreamController<int>.broadcast();
  final String message;
  final bool userGenerated;

  ChatMessage({required super.key, this.message = "", this.userGenerated = false});

  void addMessage(String message) {
    Logger.log("{$message}");
    messageController.add(message);
  }

  void trim() {
    trimController.add(0);
  }

  void finalise() {
    finaliseController.add(0);
  }

  @override
  ChatMessageState createState() => ChatMessageState();
}

class ChatMessageState extends State<ChatMessage> with SingleTickerProviderStateMixin {
  final List<Widget> _messageWidgets = [];
  String _buffer = "";
  String _message = "";
  bool _finalised = false;
  bool _inCodeBox = false;

  @override
  void initState() {
    super.initState();
    
    int keyValue = 0;
    if (widget.key != null) {
      keyValue = (widget.key as ValueKey<int>).value;
    }

    if (settings.getChat(keyValue).isNotEmpty) {
      _parseMessage(settings.getChat(keyValue));
      _finalised = true;
    } else if (widget.message.isNotEmpty) {
      _parseMessage(widget.message);
      settings.insertChat(keyValue, widget.message, widget.userGenerated);
      _finalised = true;
    } else {
      widget.messageController.stream.listen((textChunk) {
        setState(() {
          _message += textChunk;
          
          if (_messageWidgets.isEmpty) {
            _messageWidgets.add(const Text("")); // Placeholder
          }

          if (textChunk.contains('```')) {
            if (_inCodeBox) {
              _messageWidgets.last = CodeBox(code: _buffer.trim());
            } else {
              _messageWidgets.last = SelectableText(_buffer.trim());
            }
            _inCodeBox = !_inCodeBox;
            _messageWidgets.add(const SizedBox(height: 10));
            _messageWidgets.add(const Text("")); // Placeholder
            _buffer = "";
          } else {
            if (_inCodeBox) {
              _buffer += textChunk;
              _messageWidgets.last = CodeBox(code: _buffer);
            } else {
              _buffer += textChunk;
              _messageWidgets.last = SelectableText(_buffer);
            }
          }
        });
      });

      widget.trimController.stream.listen((_) {
        setState(() {
          _message = _message.trimRight();
        });
      });

      widget.finaliseController.stream.listen((_) {
        setState(() {
          settings.insertChat(keyValue, _message, widget.userGenerated);
          _finalised = true;
        });
      });
    }
  }

  void _parseMessage(String message) {
    List<String> parts = message.split('```');
    for (int i = 0; i < parts.length; i++) {
      String part = parts[i].trim();
      if (part.isEmpty) continue;

      if (i % 2 == 0) { // Even index, regular text
        _messageWidgets.add(SelectableText(part));
      } else { // Odd index, code box
        _messageWidgets.add(CodeBox(code: part));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
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
        child: !_finalised && _messageWidgets.isEmpty
          ? const TypingIndicator()
          : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _messageWidgets,
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.messageController.close();
    widget.trimController.close();
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
