import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maid_llm/src/chat_node.dart';
import 'package:maid/classes/large_language_model.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/static/logger.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class ChatField extends StatefulWidget {
  const ChatField({super.key});

  @override
  State<ChatField> createState() => _ChatFieldState();
}

class _ChatFieldState extends State<ChatField> {
  final TextEditingController _promptController = TextEditingController();
  StreamSubscription? _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid || Platform.isIOS) {
      // For sharing or opening text coming from outside the app while the app is in the memory
      _intentDataStreamSubscription =
          ReceiveSharingIntent.instance.getMediaStream().listen((value) {
        setState(() {
          _promptController.text = value.first.path;
        });
      }, onError: (err) {
        Logger.log("Error: $err");
      });

      // For sharing or opening text coming from outside the app while the app is closed
      ReceiveSharingIntent.instance.getInitialMedia().then((value) {
        setState(() {
          _promptController.text = value.first.path;
        });
      });
    }
  }

  @override
  void dispose() {
    _intentDataStreamSubscription?.cancel();
    super.dispose();
  }

  void send() async {
    if (Platform.isAndroid || Platform.isIOS) {
      FocusScope.of(context).unfocus();
    }

    final session = context.read<Session>();

    
    session.chat.add(
      UniqueKey(), 
      content: _promptController.text.trim(), 
      role: ChatRole.user
    );

    session.chat.add(
      UniqueKey(),
      role: ChatRole.assistant
    );

    session.notify();

    session.prompt(context);

    setState(() {
      _promptController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(builder: (context, session, child) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            if (session.isBusy &&
                session.model.type != LargeLanguageModelType.ollama)
              IconButton(
                  onPressed: session.stop,
                  iconSize: 50,
                  icon: const Icon(
                    Icons.stop_circle_sharp,
                    color: Colors.red,
                  )),
            Expanded(
              child: TextField(
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 9,
                enableInteractiveSelection: true,
                controller: _promptController,
                cursorColor: Theme.of(context).colorScheme.secondary,
                decoration: InputDecoration(
                  labelText: 'Prompt',
                  hintStyle: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
            IconButton(
                onPressed: () {
                  if (!session.isBusy) {
                    send();
                  }
                },
                iconSize: 50,
                icon: Icon(
                  Icons.arrow_circle_right,
                  color: session.isBusy
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.secondary,
                )),
          ],
        ),
      );
    });
  }
}
