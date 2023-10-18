import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maid/model.dart';
import 'package:maid/theme.dart';
import 'package:maid/widgets/drawer_widget.dart';
import 'package:maid/widgets/chat_widgets.dart';

class MaidHomePage extends StatefulWidget {
  const MaidHomePage({super.key, required this.title});

  final String title;

  @override
  State<MaidHomePage> createState() => _MaidHomePageState();
}

class _MaidHomePageState extends State<MaidHomePage> {
  final ScrollController _consoleScrollController = ScrollController();
  List<Widget> chatWidgets = [];
  ResponseMessage newResponse = ResponseMessage();
  
  int historyLength = 0;
  int responseLength = 0;
  Lib? lib;

  int characterMatch = 0;
  int lineBreakMatch = 0;

  bool canStop = false;

  void _exec() {
    //close the keyboard if on mobile
    if (Platform.isAndroid || Platform.isIOS) {
      FocusScope.of(context).unfocus();
    }
    setState(() {
      model.saveAll();
      chatWidgets.add(UserMessage(message: model.promptController.text.trim()));
      model.promptController.text += '\n${model.responseAliasController.text}';
      model.compilePrePrompt();
      historyLength = model.promptController.text.trim().length + 2;
      historyLength += (responseLength == 0) ? model.prePrompt.length : 0;
      responseLength = 0;
      model.inProgress = true;
    });
    if (lib == null) {
      lib = Lib.instance;
      lib?.butlerStart(printResult);
    } else {
      lib?.butlerContinue();
    }
    setState(() {
      newResponse = ResponseMessage();
      chatWidgets.add(newResponse);
      model.promptController.text = ""; // Clear the input field
    });
  }

  void scrollDown() {
    _consoleScrollController.animateTo(
      _consoleScrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 50),
      curve: Curves.easeOut,
    );
  }

  void printResult(String message) {
    String alias = model.userAliasController.text;
    int i = 0;

    if (!model.inProgress) {
      return;
    }

    while (i < message.length) {
      responseLength++;

      if (responseLength > historyLength) {
        // If the current character matches the expected character in the model text
        if (message[i] == alias[characterMatch]) {
          characterMatch++;
        
          // If the entire model text is matched, reset the match position
          if (characterMatch >= alias.length) {
            model.inProgress = false;
            break;
          }
        } else if (message[i] == '\n') {
          lineBreakMatch++;

          if (lineBreakMatch >= 3) {
            model.inProgress = false;
            break;
          }
        } else {
          // If there's a mismatch, add the remaining message to newResponse
          newResponse.addMessage(message.substring(i - characterMatch));
          scrollDown();
          characterMatch = 0;
          return;
        }
      }
    
      i++;
    }

    if (!model.inProgress) {
      characterMatch = 0;
      lineBreakMatch = 0;
      lib?.butlerStop();
      newResponse.trim();
      newResponse.finalise();
      return;
    }
  }

  void done() {
    setState(() {
      model.inProgress = false;
      newResponse.trim();
      newResponse.finalise();
    });
  }

  void canUseStop() {
    setState(() {
      canStop = true;
    });
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
        title: Text(
          widget.title
        ),
      ),
      drawer: const MaidDrawer(),
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
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.multiline,
                            onSubmitted: (value) => _exec(),
                            controller: model.promptController,
                            cursorColor: Theme.of(context).colorScheme.secondary,
                            decoration: roundedInput('Prompt', context)
                          ),
                        ),
                        IconButton(
                          onPressed: _exec, 
                          iconSize: 50,
                          icon: Icon(Icons.arrow_circle_right, 
                            color: Theme.of(context).colorScheme.secondary,
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