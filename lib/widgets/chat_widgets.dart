import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class UserMessage extends StatelessWidget {
  final String message;

  const UserMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: SelectableText(message),
      ),
    );
  }
}

class ResponseMessage extends StatefulWidget {
  final StreamController<String> messageController =
      StreamController<String>.broadcast();
  final StreamController<int> trimController =
      StreamController<int>.broadcast();
  final StreamController<int> finaliseController =
      StreamController<int>.broadcast();

  ResponseMessage({super.key});

  void addMessage(String message) {
    print("{$message}");
    messageController.add(message);
  }

  void trim() {
    trimController.add(0);
  }

  void finalise() {
    finaliseController.add(0);
  }

  @override
  _ResponseMessageState createState() => _ResponseMessageState();
}

class _ResponseMessageState extends State<ResponseMessage> with SingleTickerProviderStateMixin {
  List<Widget> _messageWidgets = [const Text("")];
  String _message = "";
  bool _finalised = false; // Declare finalised here
  bool _inCodeBox = false;

  @override
  void initState() {
    super.initState();
    widget.messageController.stream.listen((textChunk) {
      setState(() {
        if (textChunk.contains('```')) {
          if (_inCodeBox) {
            _messageWidgets.last = CodeBox(code: _message.trim());
          } else {
            _messageWidgets.last = SelectableText(_message.trim());
          }
          _inCodeBox = !_inCodeBox;
          _messageWidgets.add(const SizedBox(height: 10));
          _messageWidgets.add(const Text("")); // Placeholder
          _message = "";
        } else {
          if (_inCodeBox) {
            _message += textChunk;
            _messageWidgets.last = CodeBox(code: _message);
          } else {
            _message += textChunk;
            _messageWidgets.last = SelectableText(_message);
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
        _finalised = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
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
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
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
            child: SelectableText(
              code,
              style: const TextStyle(fontFamily: 'monospace'),
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