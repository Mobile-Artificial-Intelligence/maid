import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maid/ModelFilePath.dart';
import 'package:maid/lib.dart';
import 'package:maid/model.dart';
import 'package:maid/llama_params.dart';
import 'package:maid/widgets/settings_widget.dart';
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
  
  String log = "";
  String result = "";
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

  void printLnLog(String log) {
    setState(() {
      this.log += "$log\n";
    });
    scrollDown();
  }

  void printResult(String log) {
    setState(() {
      result += log;
    });
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
        paramsLlamaValuesOnly: ParamsLlamaValuesOnly(
          memory_f16: model.paramsLlama.memory_f16,
          random_prompt: model.paramsLlama.random_prompt,
          use_color: model.paramsLlama.use_color,
          interactive: model.paramsLlama.interactive,
          interactive_start: model.paramsLlama.interactive_start,
          instruct: model.paramsLlama.instruct,
          ignore_eos: model.paramsLlama.ignore_eos,
          perplexity: model.paramsLlama.perplexity,
          seed: model.paramsLlama.seedController.text,
          n_threads: model.paramsLlama.n_threadsController.text,
          n_predict: model.paramsLlama.n_predictController.text,
          repeat_last_n: model.paramsLlama.repeat_last_nController.text,
          n_parts: model.paramsLlama.n_partsController.text,
          n_ctx: model.paramsLlama.n_ctxController.text,
          top_k: model.paramsLlama.top_kController.text,
          top_p: model.paramsLlama.top_pController.text,
          temp: model.paramsLlama.tempController.text,
          repeat_penalty: model.paramsLlama.repeat_penaltyController.text,
          n_batch: model.paramsLlama.n_batchController.text,
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
      lib?.newPromp(
          " ${model.promptController.text.trim()}${model.promptController.text.isEmpty ? "" : "\n"}");
    }
    setState(() {
      model.promptController.text = "";
    });
  }

  void _cancel() {
    lib?.cancel(
        // printLnLog: printLnLog,
        // printLog: printLog,
        );
  }

  showPrepromptAlert() async {
    var prePrompts = await model.getPrePrompts();
    showDialog(
      context: context,
      builder: (BuildContext contextAlert) {
        return AlertDialog(
          title: const Text("Pre-Prompt"),
          content: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 300,
            ),
            child: SingleChildScrollView(
              child: ListBody(
                children: [
                  for (var prePrompt in prePrompts)
                    Wrap(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                                width: 1,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 1,
                                ),
                              ],
                              color: Colors.white,
                            ),
                            child: ListTile(
                              title: Text(prePrompt,
                                  style: const TextStyle(
                                    color: Colors.black,
                                  )),
                              onTap: () {
                                setState(() {
                                  model.prePrompt = prePrompt;
                                });
                                SharedPreferences.getInstance().then((prefs) {
                                  prefs.setString(
                                      "defaultPrePrompt", prePrompt);
                                });
                                Navigator.of(contextAlert).pop();
                              },
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.all(0),
                                ),
                                onPressed: () {
                                  deletePrompt(prePrompt);
                                  Navigator.of(contextAlert).pop();
                                },
                                child: const Text(
                                  "X",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ElevatedButton(
                    onPressed: () async {
                      await addPrePromptAlert();
                      //save prePrompt in shared preferences
                      prePrompts.add(model.prePrompt);
                      Navigator.of(contextAlert).pop();
                    },
                    child: const Text("+",
                        style: TextStyle(
                          color: Colors.white,
                        )),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("OK",
                  style: TextStyle(
                    color: Colors.cyan,
                  )),
              onPressed: () {
                setState(() {
                  model.prePrompt = model.promptController.text;
                });
                Navigator.of(contextAlert).pop();
              },
            ),
          ],
        );
      },
    );
  }

  addPrePromptAlert() {
    var prePromptController = TextEditingController();
    return showDialog(
      context: context,
      builder: (BuildContext contextAlert) {
        return AlertDialog(
          title: const Text("Add a new Pre-Prompt"),
          content: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 300,
            ),
            child: SingleChildScrollView(
              child: ListBody(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 200,
                    ),
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      expands: false,
                      controller: prePromptController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(
                          color: Colors.cyan,
                        ),
                        labelText: 'New Pre-Prompt',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                "OK",
                style: TextStyle(
                  color: Colors.cyan,
                ),
              ),
              onPressed: () async {
                setState(() {
                  model.prePrompt = prePromptController.text;
                });
                //save prePrompt in shared preferences
                var prePrompts = await model.getPrePrompts();
                prePrompts.add(model.prePrompt);
                var prefs = await SharedPreferences.getInstance();
                prefs.setStringList("prePrompts", prePrompts);
                Navigator.of(contextAlert).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void deletePreprompt() {
    setState(() {
      model.prePrompt = "";
    });
  }

  void showSettings() {
    showDialog(
      context: context, 
      builder: (BuildContext contextAlert) {
        return AlertDialog(
          title: const Text("Settings"),
          content: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 300,
            ),
            child: SingleChildScrollView(
              child: ListBody(
                children: [
                  const Text("RAM :"),
                  //Text(
                  //  _ram,
                  //  style: TextStyle(
                  //    color: color,
                  //    fontWeight: FontWeight.bold,
                  //  ),
                  //),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      model.openFile();
                    },
                    child: const Text(
                      "Load Model",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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

  void deletePrompt(String prePrompt) async {
    var prefs = await SharedPreferences.getInstance();
    List<String>? prePrompts = [];
    if (prefs.containsKey("prePrompts")) {
      prePrompts = prefs.getStringList("prePrompts") ?? [];
    }
    prePrompts.remove(prePrompt);
    prefs.setStringList("prePrompts", prePrompts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade800,  // Set a solid color here
          ),
        ),
        title: GestureDetector(
          onTap: () {
            showInfosAlert();
          },
          child: Text(widget.title),
        ),
      ),
      endDrawer: SettingsWidget(model: model),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple.shade900,
                  Colors.cyan.shade900,
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 700,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showParams = !showParams;
                            });
                          },
                          child: const Icon(
                            Icons.settings,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (model.fileState == FileState.found) ...[
                        if (showParams) ...[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    ElevatedButton(
                                        onPressed: showPrepromptAlert,
                                        child: const Text(
                                          "Pre-Prompt",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: ElevatedButton(
                                            onPressed: deletePreprompt,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              padding:
                                                  const EdgeInsets.all(0.0),
                                            ),
                                            child: const Text(
                                              "X",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxHeight: 200,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SingleChildScrollView(
                                            child: SelectableText(
                                              "Pre-Prompt : ${model.prePrompt}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 1,
                                    expands: false,
                                    controller: model.reversePromptController,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      labelStyle: const TextStyle(
                                        color: Colors.cyan,
                                      ),
                                      labelText: 'Reverse Prompt',
                                      suffixIcon: IconButton(
                                          onPressed: () {
                                            model.reversePromptController.clear();
                                          },
                                          icon: const Icon(Icons.clear)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: toggleShowFineTune,
                              child: Text(
                                showParamsFineTune
                                    ? "Hide Params"
                                    : "Show Params",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          //if (showParamsFineTune)
                          //  Padding(
                          //    padding: const EdgeInsets.all(8.0),
                          //    child: Container(
                          //      decoration: BoxDecoration(
                          //        border: Border.all(color: Colors.cyan),
                          //        borderRadius: BorderRadius.circular(5),
                          //      ),
                          //      child: Padding(
                          //        padding: const EdgeInsets.all(8.0),
                          //        child: SettingsWidget(model: model), // SettingWidget is now a drawer
                          //      ),
                          //    ),
                          //  ),
                          ElevatedButton(
                            onPressed: toggleShowLog,
                            child: Text(
                              showLog ? "Hide Log" : "Show Log",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          if (showLog)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.cyan),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Column(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 8.0),
                                      child: Text("Log"),
                                    ),
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxHeight: 200,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SingleChildScrollView(
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: Colors.black,
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    log,
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                        const Text(
                          "Chat now !",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Stack(
                          children: [
                            //top right button to copy the result
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height - 200),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SingleChildScrollView(
                                  controller: _consoleScrollController,
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.black,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: SelectableText(
                                            result,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (result.isNotEmpty)
                              Positioned(
                                top: 12,
                                right: 8,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(0),
                                    backgroundColor:
                                        Colors.blueGrey.withOpacity(0.5),
                                  ),
                                  onPressed: () {
                                    Clipboard.setData(
                                        ClipboardData(text: result));
                                    //delete the toast if it is already present
                                    ScaffoldMessenger.of(context)
                                        .removeCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text("Text copied to clipboard"),
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    Icons.copy,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            TextField(
                              keyboardType: TextInputType.multiline,
                              // maxLines: 3,
                              //on enter send the message
                              onSubmitted: (value) {
                                _exec();
                              },
                              expands: false,
                              controller: model.promptController,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelStyle: const TextStyle(
                                  color: Colors.cyan,
                                ),
                                labelText: 'Prompt',
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ElevatedButton(
                                        onPressed: (model.inProgress) ? null : _exec,
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 5),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (!model.inProgress)
                                              const Icon(
                                                Icons.send_sharp,
                                                color: Colors.white,
                                              ),
                                            if (model.inProgress)
                                              const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      if (canStop && model.inProgress)
                                        ElevatedButton(
                                          onPressed: _cancel,
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 5),
                                          ),
                                          child: const Icon(
                                            Icons.stop,
                                            color: Colors.white,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}