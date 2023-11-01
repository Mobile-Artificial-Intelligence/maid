import 'dart:io';
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:system_info2/system_info2.dart';

import 'package:maid/config/settings.dart';
import 'package:maid/config/model.dart';
import 'package:maid/config/butler.dart';

import 'package:maid/pages/character_page.dart';
import 'package:maid/pages/model_page.dart';
import 'package:maid/pages/settings_page.dart';
import 'package:maid/pages/about_page.dart';


class MaidHomePage extends StatefulWidget {
  final String title;

  const MaidHomePage({super.key, required this.title});


  @override
  State<MaidHomePage> createState() => _MaidHomePageState();
}

class _MaidHomePageState extends State<MaidHomePage> {
  final ScrollController _consoleScrollController = ScrollController();
  TextEditingController promptController = TextEditingController();
  static int ram = SysInfo.getTotalPhysicalMemory() ~/ (1024 * 1024 * 1024);
  List<Widget> chatWidgets = [];
  ResponseMessage newResponse = ResponseMessage();

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

    setState(() {
      model.busy = true;
      chatWidgets.add(UserMessage(message: promptController.text.trim()));
    });

    if (!Lib.instance.hasStarted()) {
      await settings.save();
      Lib.instance.butlerStart(promptController.text, responseCallback);
    } else {
      Lib.instance.butlerContinue(promptController.text);
    }

    setState(() {
      newResponse = ResponseMessage();
      chatWidgets.add(newResponse);
      promptController.clear();
    });
  }

  void scrollDown() {
    _consoleScrollController.animateTo(
      _consoleScrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 50),
      curve: Curves.easeOut,
    );
  }

  void responseCallback(String message) {
    if (!model.busy) {
      newResponse.trim();
      newResponse.finalise();
      setState(() {});
      return;
    } else if (message.isNotEmpty) {
      newResponse.addMessage(message);
      scrollDown();
    }
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
    Settings.log("{$message}");
    messageController.add(message);
  }

  void trim() {
    trimController.add(0);
  }

  void finalise() {
    finaliseController.add(0);
  }

  @override
  ResponseMessageState createState() => ResponseMessageState();
}

class ResponseMessageState extends State<ResponseMessage> with SingleTickerProviderStateMixin {
  final List<Widget> _messageWidgets = [];
  String _message = "";
  bool _finalised = false; // Declare finalised here
  bool _inCodeBox = false;

  @override
  void initState() {
    super.initState();
    widget.messageController.stream.listen((textChunk) {
      setState(() {
        if (_messageWidgets.isEmpty) {
          _messageWidgets.add(const Text("")); // Placeholder
        }
        
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
  TypingIndicatorState createState() => TypingIndicatorState();
}

class TypingIndicatorState extends State<TypingIndicator>
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