import 'dart:async';
import 'dart:math';

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
        child: Text(message),
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

  ResponseMessage({Key? key}) : super(key: key);

  void addMessage(String message) {
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
  String _message = "";
  late AnimationController _repeatingController;
  final List<Interval> _dotIntervals = const [
    Interval(0.25, 0.8),
    Interval(0.35, 0.9),
    Interval(0.45, 1.0),
  ];
  bool _finalised = false; // Declare finalised here

  @override
  void initState() {
    super.initState();
    _repeatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    widget.messageController.stream.listen((textChunk) {
      setState(() {
        _message += textChunk;
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

    if (!_finalised) { // Use _finalised instead of widget.finalised
      _repeatingController.repeat();
    }
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
        child: !_finalised && _message.isEmpty
          ? SizedBox(
              width: 50,  // Adjust width to your needs
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  _dotIntervals.length,
                  (index) => AnimatedBuilder(
                    animation: _repeatingController,
                    builder: (context, child) {
                      final circleFlashPercent = _dotIntervals[index].transform(
                        _repeatingController.value,
                      );
                      final circleColorPercent = sin(pi * circleFlashPercent);
                      return Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.lerp(
                            Theme.of(context).colorScheme.background, // flashingCircleDarkColor
                            Theme.of(context).colorScheme.secondary, // flashingCircleBrightColor
                            circleColorPercent,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            )
          : Text(_message),
      ),
    );
  }

  @override
  void dispose() {
    widget.messageController.close();
    widget.trimController.close();
    _repeatingController.dispose();
    super.dispose();
  }
}