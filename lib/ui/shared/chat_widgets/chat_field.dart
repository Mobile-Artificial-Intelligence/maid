import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:maid/ui/mobile/widgets/dialogs.dart';
import 'package:maid/classes/chat_node.dart';
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
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
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
        if (value.isNotEmpty) {
          setState(() {
            _promptController.text = value.first.path;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _intentDataStreamSubscription?.cancel();
    super.dispose();
  }

  void send() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      FocusScope.of(context).unfocus();
    }

    final session = context.read<Session>();

    
    session.chat.add(
      content: _promptController.text.trim(), 
      role: ChatRole.user
    );

    session.chat.add(
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
    return SafeArea(
      minimum: const EdgeInsets.all(8.0),
      child: _buildRow(),
    );
  }

  Widget _buildRow() {
    return Consumer<Session>(builder: (context, session, child) {
      return Row(
        children: [
          if (!session.chat.tail.finalised &&
              session.model.type != LargeLanguageModelType.ollama)
            Semantics(
              label: 'Stop button',
              hint: 'Double tap to stop inference.',
              excludeSemantics: true,
              child: IconButton(
                onPressed: session.stop,
                iconSize: 50,
                icon: const Icon(
                  Icons.stop_circle_sharp,
                  color: Colors.red,
                )
              ),
            ),
          Expanded(
            child: Semantics(
              label: 'Prompt text field',
              hint: 'Text to be sent to the model for a response.',
              excludeSemantics: true,
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
              )
            ),
          ),
          Semantics(
            label: 'Prompt button',
            hint: 'Double tap to prompt the model for a response.',
            excludeSemantics: true,
            child: IconButton(
              onPressed: () {
                if (session.model.missingRequirements.isNotEmpty) {
                  showMissingRequirementsDialog(context);
                }
                else if (session.chat.tail.finalised) {
                  send();
                }
              },
              iconSize: 50,
              icon: Icon(
                Icons.arrow_circle_right,
                color: !session.chat.tail.finalised 
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.secondary,
              )
            )
          )
        ],
      );
    });
  }
}
