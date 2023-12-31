import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maid/models/generation_options.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/providers/model.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/static/generation_manager.dart';
import 'package:provider/provider.dart';

class ChatField extends StatefulWidget {
  const ChatField({super.key});

  @override
  State<ChatField> createState() => _ChatFieldState();
}

class _ChatFieldState extends State<ChatField> {
  final TextEditingController _promptController = TextEditingController();

  void send() {
    if (Platform.isAndroid || Platform.isIOS) {
      FocusScope.of(context).unfocus();
    }

    final model = context.read<Model>();
    final character = context.read<Character>();
    final session = context.read<Session>();
    final genContext =
        GenerationOptions(model: model, character: character, session: session);

    final key = UniqueKey();

    session
        .add(UniqueKey(),
            message: _promptController.text.trim(), userGenerated: true)
        .then((value) {
      session.add(key);
    });

    GenerationManager.prompt(_promptController.text.trim(), genContext,
        session.stream);

    setState(() {
      _promptController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              if (session.isBusy &&
                  context.read<Model>().apiType != ApiType.ollama)
                const IconButton(
                    onPressed: GenerationManager.stop,
                    iconSize: 50,
                    icon: Icon(
                      Icons.stop_circle_sharp,
                      color: Colors.red,
                    )),
              Expanded(
                child: RawKeyboardListener(
                  focusNode: FocusNode(),
                  onKey: (event) {
                    if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                      if (event.isControlPressed) {
                        // Insert line break when Ctrl+Enter is pressed
                        int currentPos = _promptController.selection.baseOffset;
                        String text = _promptController.text;
                        String newText =
                            "${text.substring(0, currentPos)}\n${text.substring(currentPos)}";
                        _promptController.text = newText;
                        // Position the cursor after the new line character
                        _promptController.selection = TextSelection.fromPosition(
                            TextPosition(offset: currentPos + 1));
                      } else if (!session.isBusy) {
                        // Submit the form when Enter is pressed without Ctrl
                        send();
                      }
                    }
                  },
                  child: TextField(
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.none,
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
      }
    );
  }
}
