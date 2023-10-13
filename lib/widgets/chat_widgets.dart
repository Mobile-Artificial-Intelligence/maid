import 'dart:async';

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
  final StreamController<String> messageController = StreamController<String>.broadcast();
  final StreamController<int> trimController = StreamController<int>.broadcast();

  ResponseMessage({super.key}); // 1. Add remove controller

  void addMessage(String message) {
    messageController.add(message);
  }

  void trim() {
    trimController.add(0);
  }

  @override
  _ResponseMessageState createState() => _ResponseMessageState();
}

class _ResponseMessageState extends State<ResponseMessage> {
  String _message = "";

  @override
  void initState() {
    super.initState();

    // Listening for new messages
    widget.messageController.stream.listen((textChunk) {
      setState(() {
        _message += textChunk;
      });
    });

    // Listen for the trim request
    widget.trimController.stream.listen((_) {
      setState(() {
        _message = _message.trimRight();
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
        child: Text(_message),
      ),
    );
  }

  @override
  void dispose() {
    widget.messageController.close();
    widget.trimController.close(); // Close trim controller
    super.dispose();
  }
}