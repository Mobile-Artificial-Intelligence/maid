import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maid/static/generation_manager.dart';
import 'package:maid/static/host.dart';
import 'package:maid/static/memory_manager.dart';
import 'package:maid/static/message_manager.dart';
import 'package:maid/widgets/settings_widgets/maid_text_field.dart';

import 'package:system_info2/system_info2.dart';

import 'package:maid/types/model.dart';
import 'package:maid/core/local_generation.dart';

import 'package:maid/pages/character_page.dart';
import 'package:maid/pages/model_page.dart';
import 'package:maid/pages/settings_page.dart';
import 'package:maid/pages/about_page.dart';

import 'package:maid/widgets/chat_widgets/chat_message.dart';

class MaidHomePage extends StatefulWidget {
  final String title;

  const MaidHomePage({super.key, required this.title});

  @override
  MaidHomePageState createState() => MaidHomePageState();
}

class MaidHomePageState extends State<MaidHomePage> {
  final ScrollController _consoleScrollController = ScrollController();
  TextEditingController promptController = TextEditingController();
  static int ram = SysInfo.getTotalPhysicalMemory() ~/ (1024 * 1024 * 1024);
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
                          builder: (context) => const ModelPage()));
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
    MemoryManager.saveAll().then((value) {
      if (Platform.isAndroid || Platform.isIOS) {
        FocusScope.of(context).unfocus();
      }

      MessageManager.add(UniqueKey(), 
        message: promptController.text.trim(), 
        userGenerated: true
      );
      MessageManager.add(UniqueKey());

      if (GenerationManager.remote && 
        Host.url.isNotEmpty && 
        model.parameters["remote_model"] != null
      ) {
        GenerationManager.prompt(promptController.text.trim());
        setState(() {
          MessageManager.busy = true;
          promptController.clear();
        });
      } else if (!GenerationManager.remote && 
        MemoryManager.checkFileExists(model.parameters["path"])
      )  {
        GenerationManager.prompt(promptController.text.trim());
        setState(() {
          MessageManager.busy = true;
          promptController.clear();
        });
      } else {
        _missingModelDialog();
        setState(() {
          MessageManager.busy = false;
          promptController.clear();
        });
      }
    });
  }

  void updateCallback() {
    chatWidgets.clear();
    Map<Key, bool> history = MessageManager.history();
    for (var key in history.keys) {
      chatWidgets.add(ChatMessage(
        key: key,
        userGenerated: history[key] ?? false,
      ));
    }
    _consoleScrollController.animateTo(
      _consoleScrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 50),
      curve: Curves.easeOut,
    );
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    chatWidgets.clear();
    Map<Key, bool> history = MessageManager.history();
    for (var key in history.keys) {
      chatWidgets.add(ChatMessage(
        key: key,
        userGenerated: history[key] ?? false,
      ));
    }
    MessageManager.registerCallback(updateCallback);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
          ),
        ),
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(
              height: 50,
            ),
            Text(
              ram == -1 ? 'RAM: Unknown' : 'RAM: $ram GB',
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    Color.lerp(Colors.red, Colors.green, ram.clamp(0, 8) / 8) ??
                        Colors.red,
                fontSize: 15,
              ),
            ),
            Divider(
              indent: 10,
              endIndent: 10,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            ListTile(
              leading: Icon(Icons.person,
                  color: Theme.of(context).colorScheme.onPrimary),
              title: Text('Character',
                  style: Theme.of(context).textTheme.labelLarge),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CharacterPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.account_tree_rounded,
                  color: Theme.of(context).colorScheme.onPrimary),
              title: Text(
                'Model',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const ModelPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.settings,
                  color: Theme.of(context).colorScheme.onPrimary),
              title: Text('Settings',
                  style: Theme.of(context).textTheme.labelLarge),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.info,
                  color: Theme.of(context).colorScheme.onPrimary),
              title:
                  Text('About', style: Theme.of(context).textTheme.labelLarge),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const AboutPage()));
              },
            ),
            Divider(
              indent: 10,
              endIndent: 10,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            SwitchListTile(
              title: const Text('Local / Remote'),
              value: GenerationManager.remote,
              onChanged: (value) {
                setState(() {
                  GenerationManager.remote = value;
                });
              },
            ),
            if (GenerationManager.remote)
              MaidTextField(
                headingText: 'URL', 
                labelText: 'URL',
                initialValue: Host.url,
                onChanged: (value) {
                  Host.url = value;
                },
              ),
          ],
        ),
      ),
      body: Builder(
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
                        if (MessageManager.busy && !GenerationManager.remote)
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
                              if (!MessageManager.busy) {
                                if (model.parameters["path"]
                                    .toString()
                                    .isEmpty && !GenerationManager.remote) {
                                  _missingModelDialog();
                                } else {
                                  send();
                                }
                              }
                            },
                            controller: promptController,
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
                              if (!MessageManager.busy) {
                                if (model.parameters["path"]
                                    .toString()
                                    .isEmpty && !GenerationManager.remote) {
                                  _missingModelDialog();
                                } else {
                                  send();
                                }
                              }
                            },
                            iconSize: 50,
                            icon: Icon(
                              Icons.arrow_circle_right,
                              color: MessageManager.busy
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
      ),
    );
  }
}
