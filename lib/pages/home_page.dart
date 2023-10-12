import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maid/lib.dart';
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
  
  String log = "";
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
      model.compilePrePrompt();
      historyLength = model.promptController.text.trim().length +
                      model.responseAliasController.text.trim().length + 3;
      historyLength += (responseLength == 0) ? model.prePrompt.length : 0;
      responseLength = 0;
      model.inProgress = true;
    });
    if (lib == null) {
      lib = Lib();
      lib?.executeBinary(
        model: model,
        paramsLlama: ParamsLlama(
          memory_f16: model.memory_f16,
          random_prompt: model.random_prompt,
          use_color: model.use_color,
          interactive: model.interactive,
          interactive_start: model.interactive_start,
          instruct: model.instruct,
          ignore_eos: model.ignore_eos,
          perplexity: model.perplexity,
          seed: model.seedController.text,
          n_threads: model.n_threadsController.text,
          n_predict: model.n_predictController.text,
          repeat_last_n: model.repeat_last_nController.text,
          n_parts: model.n_partsController.text,
          n_ctx: model.n_ctxController.text,
          top_k: model.top_kController.text,
          top_p: model.top_pController.text,
          temp: model.tempController.text,
          repeat_penalty: model.repeat_penaltyController.text,
          n_batch: model.n_batchController.text,
        ),
        printLnLog: printLnLog,
        printLog: printResult,
        promptPassed: model.prePrompt,
        firstInteraction: model.promptController.text.trim() +
            (model.promptController.text.isEmpty ? "" : "\n"),
        done: done,
        canStop: canUseStop,
        stopToken: model.reversePromptController.text,
      );
    } else {
      lib?.newPrompt(
          " ${model.promptController.text.trim()}${model.promptController.text.isEmpty ? "" : "\n"}");
    }
    setState(() {
      chatWidgets.add(UserMessage(message: model.promptController.text.trim()));
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

  void printLnLog(String message) {
    setState(() {
      log += "$message\n";
    });
    scrollDown();
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
      lib?.cancel();
      newResponse.trim();
      return;
    }
  }

  void done() {
    setState(() {
      model.inProgress = false;
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
            color: Theme.of(context).colorScheme.primary,
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
                  color: Theme.of(context).colorScheme.primary,
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
                            cursorColor: Theme.of(context).colorScheme.tertiary, // Change this color as per your design
                            decoration: roundedInput('Prompt', context)
                          ),
                        ),
                        IconButton(
                          onPressed: _exec, 
                          iconSize: 50,
                          icon: Icon(Icons.arrow_circle_right, 
                            color: Theme.of(context).colorScheme.tertiary,
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