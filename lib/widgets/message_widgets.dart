import 'dart:async';
import 'package:flutter/material.dart';

class UserMessage extends StatelessWidget {
  final String message;

  UserMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(message),
      ),
    );
  }
}

class ResponseMessage extends StatefulWidget {
  final StreamController<String> messageController = StreamController<String>.broadcast();

  void addMessage(String message) {
    messageController.add(message);
  }

  @override
  _ResponseMessageState createState() => _ResponseMessageState();
}

class _ResponseMessageState extends State<ResponseMessage> {
  String _message = "";

  @override
  void initState() {
    super.initState();
    widget.messageController.stream.listen((textChunk) {
      setState(() {
        _message += textChunk;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.green[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(_message),
      ),
    );
  }

  @override
  void dispose() {
    widget.messageController.close();
    super.dispose();
  }
}