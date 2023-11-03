import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maid/config/chat_node.dart';

import 'package:system_info2/system_info2.dart';

import 'package:maid/config/settings.dart';
import 'package:maid/config/model.dart';
import 'package:maid/config/butler.dart';

import 'package:maid/pages/character_page.dart';
import 'package:maid/pages/model_page.dart';
import 'package:maid/pages/settings_page.dart';
import 'package:maid/pages/about_page.dart';

import 'package:maid/widgets/chat_widgets.dart';

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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ModelPage()));
                },
                child: Text(
                  "Open Model Settings",
                  style: Theme.of(context).textTheme.labelLarge
                ),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Close",
                  style: Theme.of(context).textTheme.labelLarge
                ),
              ),
            ],
          );
        },
      );
      setState(() {});
    }
  }

  void execute() async {
    //close the keyboard if on mobile
    if (Platform.isAndroid || Platform.isIOS) {
      FocusScope.of(context).unfocus();
    }

    MessageManager.add(UniqueKey(), message: promptController.text.trim(), userGenerated: true);
    MessageManager.add(UniqueKey());

    if (!Lib.instance.hasStarted()) {
      await settings.save();
      Lib.instance.butlerStart(promptController.text, responseCallback);
    } else {
      Lib.instance.butlerContinue(promptController.text);
    }

    setState(() {
      model.busy = true;
      promptController.clear();
    });
  }

  void updateCallback() {
    chatWidgets.clear();
    List<ChatNode> history =  MessageManager.history();
    for (var node in history) {
      chatWidgets.add(ChatMessage(
        key: node.key as UniqueKey,
        userGenerated: node.userGenerated,
      ));
    }
    setState(() {});
  }

  void responseCallback(String message) {
    if (!model.busy) {
      MessageManager.finalise();
      setState(() {});
      return;
    } else if (message.isNotEmpty) {
      MessageManager.stream(message);
      _consoleScrollController.animateTo(
        _consoleScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 50),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
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
                color: Color.lerp(Colors.red, Colors.green, ram.clamp(0, 8) / 8) ?? Colors.red,
                fontSize: 15,
              ),
            ),
            Divider(
              indent: 10,
              endIndent: 10,
              color: Theme.of(context).colorScheme.primary,
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(
                'Character',
                style: Theme.of(context).textTheme.labelLarge
              ),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CharacterPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_tree_rounded),
              title: Text(
                'Model',
                style: Theme.of(context).textTheme.labelLarge
              ),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ModelPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(
                'Settings',
                style: Theme.of(context).textTheme.labelLarge
              ),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: Text(
                'About',
                style: Theme.of(context).textTheme.labelLarge
              ),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage()));
              },
            )
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
                        if (model.busy)
                          IconButton(
                            onPressed: Lib.instance.butlerStop,
                            iconSize: 50,
                            icon: const Icon(
                              Icons.stop_circle_sharp,
                              color: Colors.red,
                            )
                          ),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.multiline,
                            minLines: 1,
                            maxLines: 9,
                            enableInteractiveSelection: true,
                            onSubmitted:  (value) {
                              if (!model.busy) {
                                if (model.parameters["model_path"].toString().isEmpty) {
                                  _missingModelDialog();
                                } else {
                                  execute();
                                }                             
                              }                          
                            },
                            controller: promptController,
                            cursorColor:
                                Theme.of(context).colorScheme.secondary,
                            decoration: InputDecoration(
                              labelText: 'Prompt',
                              hintStyle: Theme.of(context).textTheme.labelSmall
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (!model.busy) {
                              if (model.parameters["model_path"].toString().isEmpty) {
                                _missingModelDialog();
                              } else {
                                execute();
                              }                             
                            }                          
                          },
                          iconSize: 50,
                          icon: Icon(
                            Icons.arrow_circle_right,
                            color: model.busy
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.secondary,
                          )
                        ),
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