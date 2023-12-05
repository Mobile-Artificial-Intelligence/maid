import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maid/core/local_generation.dart';
import 'package:maid/pages/generic_page.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/static/generation_manager.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/providers/model.dart';
import 'package:maid/types/generation_context.dart';
import 'package:maid/widgets/chat_widgets/chat_message.dart';
import 'package:maid/widgets/page_bodies/model_body.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatBody extends StatefulWidget {
  const ChatBody({super.key});

  @override
  State<ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends State<ChatBody> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _consoleScrollController = ScrollController();
  List<ChatMessage> chatWidgets = [];

  void _missingModelDialog() {
    // Use a local reference to context to avoid using it across an async gap.
    final localContext = context;
    // Ensure that the context is still valid before attempting to show the dialog.
    if (localContext.mounted) {
      showDialog(
        context: localContext,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              "Model Missing\nPlease assign a model in model settings.",
              textAlign: TextAlign.center,
            ),
            alignment: Alignment.center,
            actionsAlignment: MainAxisAlignment.center,
            backgroundColor: Theme.of(context).colorScheme.background,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const GenericPage(
                              title: "Model", body: ModelBody())));
                },
                child: Text("Open Model Settings",
                    style: Theme.of(context).textTheme.labelLarge),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Close",
                    style: Theme.of(context).textTheme.labelLarge),
              ),
            ],
          );
        },
      );
      setState(() {});
    }
  }

  void send() {
    if (Platform.isAndroid || Platform.isIOS) {
      FocusScope.of(context).unfocus();
    }

    final model = context.read<Model>();
    final character = context.read<Character>();
    final session = context.read<Session>();
    final genContext = GenerationContext(
      model: model,
      character: character,
      session: session
    );

    session.add(
      UniqueKey(), 
      message: _promptController.text.trim(), 
      userGenerated: true
    );
    session.add(UniqueKey());

    GenerationManager.prompt(
      _promptController.text.trim(),
      genContext,
      session.stream
    );

    setState(() {
      GenerationManager.busy = true;
      _promptController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) {
        final model = context.watch<Model>();
        
        SharedPreferences.getInstance().then((prefs) {
          prefs.setString("last_session", json.encode(session.toMap()));
        });

        Map<Key, bool> history = session.history();
        chatWidgets.clear();
        for (var key in history.keys) {
          chatWidgets.add(ChatMessage(
            key: key,
            userGenerated: history[key] ?? false,
          ));
        }

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          _consoleScrollController.animateTo(
            _consoleScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 50),
            curve: Curves.easeOut,
          );
        });

        return Builder(
          builder: (BuildContext context) => GestureDetector(
            onHorizontalDragEnd: (details) {
              // Check if the drag is towards right with a certain velocity
              if (details.primaryVelocity! > 100) {
                // Open the drawer
                Scaffold.of(context).openDrawer();
              }
            },
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                  ),
                ),
                Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _consoleScrollController,
                        itemCount: chatWidgets.length,
                        itemBuilder: (BuildContext context, int index) {
                          return chatWidgets[index];
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          if (GenerationManager.busy &&
                              model.apiType != ApiType.local)
                            IconButton(
                                onPressed: LocalGeneration.instance.stop,
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
                              onSubmitted: (value) {
                                if (!GenerationManager.busy) {
                                  send();
                                }
                              },
                              controller: _promptController,
                              cursorColor:
                                  Theme.of(context).colorScheme.secondary,
                              decoration: InputDecoration(
                                  labelText: 'Prompt',
                                  hintStyle:
                                      Theme.of(context).textTheme.labelSmall),
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                if (!GenerationManager.busy) {
                                  send();
                                }
                              },
                              iconSize: 50,
                              icon: Icon(
                                Icons.arrow_circle_right,
                                color: GenerationManager.busy
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.secondary,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
