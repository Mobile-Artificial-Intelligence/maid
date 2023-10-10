import 'dart:io';
import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maid/ModelFilePath.dart';
import 'package:maid/lib.dart';
import 'package:maid/model.dart';
import 'package:maid/widgets/settings_widget.dart';
import 'package:maid/widgets/message_widgets.dart';
import 'package:system_info_plus/system_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
 
  Model model = Model();
  List<Widget> chatWidgets = [];
  ResponseMessage newResponse = ResponseMessage();
  
  String log = "";
  Lib? lib;

  Color color = Colors.black;

  final ScrollController _consoleScrollController = ScrollController();

  // Memory? _memory;

  bool showLog = false;
  bool showParams = false;
  bool showParamsFineTune = false;

  toggleShowLog() {
    setState(() {
      showLog = !showLog;
    });
  }

  toggleShowFineTune() {
    setState(() {
      showParamsFineTune = !showParamsFineTune;
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
    newResponse.addMessage(message);
    scrollDown();
  }

  bool canStop = false;
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

  void _exec() {
    //close the keyboard if on mobile
    if (Platform.isAndroid || Platform.isIOS) {
      FocusScope.of(context).unfocus();
    }
    setState(() {
      model.inProgress = true;
    });
    if (lib == null) {
      lib = Lib();
      lib?.executeBinary(
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
        promptPassed: model.prePromptController.text,
        firstInteraction: model.promptController.text.trim() +
            (model.promptController.text.isEmpty ? "" : "\n"),
        done: done,
        canStop: canUseStop,
        stopToken: model.reversePromptController.text,
      );
    } else {
      lib?.newPromp(
          " ${model.promptController.text.trim()}${model.promptController.text.isEmpty ? "" : "\n"}");
    }
    setState(() {
      chatWidgets.add(UserMessage(message: model.promptController.text.trim()));
      newResponse = ResponseMessage();
      chatWidgets.add(newResponse);
      model.promptController.text = ""; // Clear the input field
    });
  }

  void deletePreprompt() {
    setState(() {
      model.prePromptController.text = "";
    });
  }

  void showInfosAlert() {
    showDialog(
      context: context,
      builder: (BuildContext contextAlert) {
        return AlertDialog(
          title: const Text("Infos"),
          content: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 300,
            ),
            child: SingleChildScrollView(
              child: ListBody(
                children: [
                  const SelectableText(
                      "This app is a demo of the llama.cpp model.\n\n"
                      "You can find the source code of this app on GitHub\n\n"
                      'It was made on Flutter using an implementation of ggerganov/llama.cpp recompiled to work on mobiles\n\n'
                      'The LLaMA models are officially distributed by Meta and will never be provided by us\n\n'
                      'It was made by Maxime GUERIN and Thibaut LEAUX from the french company Bip-Rep based in Lyon (France)'),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: () async {
                      var url = 'https://bip-rep.com';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    child: Image.asset(
                      "assets/biprep.jpg",
                      width: 100,
                      height: 100,
                    ),
                  ),
                ],
              ),
            ),
          )
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade900,  // Set a solid color here
          ),
        ),
        title: GestureDetector(
          onTap: () {
            showInfosAlert();
          },
          child: Text(widget.title),
        ),
      ),
      drawer: SettingsWidget(model: model),
      body: Stack(
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
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Prompt',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: model.inProgress ? null : _exec,
                      child: const Text('Send'),
                    ),
                    ElevatedButton(
                      onPressed: model.inProgress ? lib?.cancel : null,
                      child: const Text('Stop'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}