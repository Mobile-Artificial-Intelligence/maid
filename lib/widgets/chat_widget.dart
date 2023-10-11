import 'dart:io';
import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maid/lib.dart';
import 'package:maid/model.dart';
import 'package:maid/widgets/settings_widget.dart';
import 'package:system_info_plus/system_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key, required this.model});

  final Model model;

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  Model get model => widget.model;

  final ScrollController _consoleScrollController = ScrollController();
  List<Widget> chatWidgets = [];
  ResponseMessage newResponse = ResponseMessage();
  
  String log = "";
  int historyLength = 0;
  int responseLength = 0;
  Lib? lib;

  int characterMatch = 0;

  bool canStop = false;

  void _exec() {
    //close the keyboard if on mobile
    if (Platform.isAndroid || Platform.isIOS) {
      FocusScope.of(context).unfocus();
    }
    setState(() {
      print("=====================================");
      model.saveAll();
      model.compilePrePrompt();
      historyLength = model.promptController.text.trim().length +
                      model.responseAliasController.text.trim().length + 3;
      historyLength += (responseLength == 0) ? model.prePrompt.length : 0;
      responseLength = 0;
      print("historyLength: $historyLength"); 
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
          print('------------->${alias[characterMatch]}');
          characterMatch++;
        
          // If the entire model text is matched, reset the match position
          if (characterMatch >= alias.length) {
            characterMatch = 0;
            model.inProgress = false;
            lib?.cancel();
            newResponse.trim();
            return;
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
    return Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
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
                        cursorColor: Colors.blue, // Change this color as per your design
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0), // Padding inside the TextField
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0), // Rounded corners with 30.0 radius
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(color: Colors.grey[400]!), // Color when TextField is enabled but not in focus
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(color: Colors.blue), // Color when TextField is in focus
                          ),
                          labelText: 'Prompt',
                          labelStyle: const TextStyle(color: Colors.grey), // Style for the label
                          fillColor: const Color.fromARGB(255, 48, 48, 48),
                          filled: true,
                          isDense: true, // This makes the TextField height smaller
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _exec, 
                      iconSize: 50,
                      icon: const Icon(Icons.arrow_circle_right, 
                        color: Colors.blue, 
                      )
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }
}

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
          color: Color.fromARGB(255, 0, 128, 255),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(message),
      ),
    );
  }
}

class ResponseMessage extends StatefulWidget {
  final StreamController<String> messageController = StreamController<String>.broadcast();
  final StreamController<int> trimController = StreamController<int>.broadcast(); // 1. Add remove controller

  void addMessage(String message) {
    messageController.add(message);
  }

  void trim() {
    trimController.add(0);
  }

  @override
  _ResponseMessageState createState() => _ResponseMessageState();
}

class _ResponseMessageState extends State<ResponseMessage> {
  String _message = "";

  @override
  void initState() {
    super.initState();

    // Listening for new messages
    widget.messageController.stream.listen((textChunk) {
      setState(() {
        _message += textChunk;
      });
    });

    // Listen for the trim request
    widget.trimController.stream.listen((_) {
      setState(() {
        _message = _message.trimRight();
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
          color: const Color.fromARGB(255, 0, 128, 255),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(_message),
      ),
    );
  }

  @override
  void dispose() {
    widget.messageController.close();
    widget.trimController.close(); // Close trim controller
    super.dispose();
  }
}