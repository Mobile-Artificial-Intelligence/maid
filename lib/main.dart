// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sherpa/ModelFilePath.dart';
import 'package:sherpa/lib.dart';
import 'package:system_info_plus/system_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sherpa',
      theme: MyThemes().getTheme(),
      // ThemeData(
      //   colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple)
      //       .copyWith(background: Colors.grey.shade800)),
      home: const MyHomePage(title: 'Sherpa'),
    );
  }
}

class MyThemes {
  static Color gradientColorA = const Color(0xFFFFFFFF);
  static Color gradientColorB = const Color(0xFF000000);

  ThemeData getTheme() {
    gradientColorA = const Color(0xFF000000);
    gradientColorB = const Color(0xFFFFFFFF);
    return _darkTheme;
  }

  static final ThemeData _darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey[700],
    colorScheme: ColorScheme.dark(
      primary: Colors.cyan.shade700,
      secondary: Colors.purple.shade900,
    ),
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String log = "";
  String result = "";
  Lib? lib;

  String _ram = "\nCalcul en cours...";
  Color color = Colors.black;
  ParamsLlama paramsLlama = ParamsLlama();

  var promptController = TextEditingController();

  final ScrollController _consoleScrollController = ScrollController();

  String prePrompt = "";

  List<String> defaultPrePrompts = [
    '### Assistant: Hello, I\'m Sherpa, your personal assistant. I can write, complex mails, code and even songs\n'
        '### Human: Hello how are you ?\n'
        '### Assistant: I\'m fine, thank you. How are you ?\n'
        '### Human: I\'m fine too, thanks.\n'
        '### Assistant: That\'s good to hear\n'
        '### Human:',
    'Sherpa : Hello, I\'m Sherpa, your personal assistant. I can write, complex mails, code and even songs\n'
        'User : Hello how are you ?\n'
        'Sherpa : I\'m fine, thank you. How are you ?\n'
        'User : I\'m fine too, thanks.\n'
        'Sherpa : That\'s good to hear\n'
        'User :',
  ];

  bool inProgress = false;

  FileState fileState = FileState.notFound;

  TextEditingController reversePromptController = TextEditingController();

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
      inProgress = false;
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
      inProgress = true;
    });
    if (lib == null) {
      lib = Lib();
      lib?.executeBinary(
        //
        // class ParamsLlamaValuesOnly {
        // bool memory_f16;
        // bool random_prompt;
        // bool use_color;
        // bool interactive;
        // bool interactive_start;
        // bool instruct;
        // bool ignore_eos;
        // bool perplexity;
        // String seed;
        // String n_threads;
        // String n_predict;
        // String repeat_last_n;
        // String n_parts;
        // String n_ctx;
        // String top_k;
        // String top_p;
        // String temp;
        // String repeat_penalty;
        // String n_batch;
        //
        // ParamsLlamaValuesOnly({
        // required this.memory_f16,
        // required this.random_prompt,
        // required this.use_color,
        // required this.interactive,
        // required this.interactive_start,
        // required this.instruct,
        // required this.ignore_eos,
        // required this.perplexity,
        // required this.seed,
        // required this.n_threads,
        // required this.n_predict,
        // required this.repeat_last_n,
        // required this.n_parts,
        // required this.n_ctx,
        // required this.top_k,
        // required this.top_p,
        // required this.temp,
        // required this.repeat_penalty,
        // required this.n_batch,
        // });
        // }

        paramsLlamaValuesOnly: ParamsLlamaValuesOnly(
          memory_f16: paramsLlama.memory_f16,
          random_prompt: paramsLlama.random_prompt,
          use_color: paramsLlama.use_color,
          interactive: paramsLlama.interactive,
          interactive_start: paramsLlama.interactive_start,
          instruct: paramsLlama.instruct,
          ignore_eos: paramsLlama.ignore_eos,
          perplexity: paramsLlama.perplexity,
          seed: paramsLlama.seedController.text,
          n_threads: paramsLlama.n_threadsController.text,
          n_predict: paramsLlama.n_predictController.text,
          repeat_last_n: paramsLlama.repeat_last_nController.text,
          n_parts: paramsLlama.n_partsController.text,
          n_ctx: paramsLlama.n_ctxController.text,
          top_k: paramsLlama.top_kController.text,
          top_p: paramsLlama.top_pController.text,
          temp: paramsLlama.tempController.text,
          repeat_penalty: paramsLlama.repeat_penaltyController.text,
          n_batch: paramsLlama.n_batchController.text,
        ),
        printLnLog: printLnLog,
        printLog: printResult,
        promptPassed: prePrompt +
            promptController.text.trim() +
            (promptController.text.isEmpty ? "" : "\n"),
        done: done,
        canStop: canUseStop,
        stopToken: reversePromptController.text,
      );
    } else {
      lib?.newPromp(
          " ${promptController.text.trim()}${promptController.text.isEmpty ? "" : "\n"}");
    }
    setState(() {
      promptController.text = "";
    });
  }

  void _cancel() {
    lib?.cancel(
        // printLnLog: printLnLog,
        // printLog: printLog,
        );
  }

  @override
  initState() {
    super.initState();
    initDefaultPrompts();
    getRam();

    testFileExisting();
  }

  void getRam() async {
    try {
      if (Platform.isWindows == false) {
        int? deviceMemory = await SystemInfoPlus.physicalMemory;
        int deviceMemoryGB = (deviceMemory ?? 0) ~/ 1024 + 1;

        setState(() {
          _ram = "${deviceMemoryGB}GB";
          if (deviceMemoryGB <= 6) {
            _ram += " (WARNING ! May not be enough)";
          } else {
            _ram += " (Should be enough)";
          }
          color = deviceMemoryGB > 6
              ? Colors.green
              : deviceMemoryGB > 4
                  ? Colors.orange
                  : Colors.red;
        });
      } else {
        setState(() {
          _ram = " Can't get RAM on Windows";
          color = Colors.red;
        });
      }
    } catch (e) {
      setState(() {
        _ram = " Can't get RAM";
        color = Colors.red;
      });
    }
  }

  showPrepromptAlert() async {
    var prePrompts = await getPrePrompts();
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
                                  this.prePrompt = prePrompt;
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
                      prePrompts.add(prePrompt);
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
                  prePrompt = promptController.text;
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
                  prePrompt = prePromptController.text;
                });
                //save prePrompt in shared preferences
                var prePrompts = await getPrePrompts();
                prePrompts.add(prePrompt);
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

  Future<List<String>> getPrePrompts() async {
    var prefs = await SharedPreferences.getInstance();
    List<String>? prePrompts = [];
    if (prefs.containsKey("prePrompts")) {
      prePrompts = prefs.getStringList("prePrompts") ?? [];
    }
    return prePrompts;
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
          ),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(contextAlert).pop();
              },
            ),
          ],
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

  void initDefaultPrompts() async {
    var prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("prePrompts")) {
      await prefs.setStringList("prePrompts", defaultPrePrompts);
    }
    var prePrompts = await getPrePrompts();
    var defaultPrePrompt = prefs.getString("defaultPrePrompt");
    if (defaultPrePrompt != null) {
      prePrompt = defaultPrePrompt;
    } else if (prePrompts.isNotEmpty) {
      prePrompt = prePrompts[0];
    }
    setState(() {});
    if (prefs.containsKey("reversePrompt")) {
      reversePromptController.text = prefs.getString("reversePrompt") ?? "";
    } else {
      reversePromptController.text = 'User :';
    }
    reversePromptController.addListener(() {
      prefs.setString("reversePrompt", reversePromptController.text);
    });
  }

  void openFile() async {
    setState(() {
      fileState = FileState.opening;
    });

    var filePath = await ModelFilePath.getFilePath(); // getting file path

    if (filePath == null) {
      print("file not found");
      setState(() {
        fileState = FileState.notFound;
      });
      return;
    }

    var file = File(filePath);
    if (!file.existsSync()) {
      print("file not found 2");
      setState(() {
        fileState = FileState.notFound;
      });
      ModelFilePath.deleteModelFile();
      return;
    }

    setState(() {
      fileState = FileState.found;
    });
  }

  void deletePreprompt() {
    setState(() {
      prePrompt = "";
    });
  }

  void testFileExisting() async {
    if (Platform.isIOS) {
      (await SharedPreferences.getInstance()).remove('path');
    }
    var found = await ModelFilePath.filePathExists();
    if (found) {
      setState(() {
        fileState = FileState.found;
      });
    } else {
      setState(() {
        fileState = FileState.notFound;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[
                Colors.purple.shade900.withAlpha(900),
                Colors.cyan.shade900.withAlpha(900),
              ],
            ),
          ),
        ),
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showInfosAlert();
            },
          ),
        ],
      ),
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
                      if (showParams)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Wrap(
                            children: [
                              const Text(
                                'Your RAM:',
                              ),
                              Text(
                                _ram,
                                style: TextStyle(
                                    color: color, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      if (fileState == FileState.notFound)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            alignment: WrapAlignment.center,
                            children: [
                              const Text(
                                'Please download the 7B ggml-model-q4 from the official link meta provided you.\n'
                                'Then open it.\n',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.red),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  openFile();
                                },
                                child: const Text(
                                  "Open file",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (fileState == FileState.found) ...[
                        if (showParams) ...[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    const Text("Change Model"),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: ElevatedButton(
                                            onPressed: () async {
                                              await ModelFilePath
                                                  .deleteModelFile();
                                              setState(() {
                                                fileState = FileState.notFound;
                                              });
                                            },
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
                                  ],
                                ),
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
                                              "Pre-Prompt : $prePrompt",
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
                                    controller: reversePromptController,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      labelStyle: const TextStyle(
                                        color: Colors.cyan,
                                      ),
                                      labelText: 'Reverse Prompt',
                                      suffixIcon: IconButton(
                                          onPressed: () {
                                            reversePromptController.clear();
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
                          if (showParamsFineTune)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.cyan),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      const Text(
                                        "Once you start a conversation, you cannot change the params.",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            paramsLlama.resetAll(setState);
                                          },
                                          child: const Text(
                                            "Reset All",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Wrap(
                                        children: [
                                          //ParamsLlama(),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxWidth: 150,
                                              ),
                                              child: Wrap(
                                                children: [
                                                  const Text(
                                                    'seed (-1 for random):',
                                                  ),
                                                  TextField(
                                                    controller: paramsLlama
                                                        .seedController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText: 'seed',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxWidth: 150,
                                              ),
                                              child: Wrap(
                                                children: [
                                                  const Text(
                                                    'n_threads:',
                                                  ),
                                                  TextField(
                                                    controller: paramsLlama
                                                        .n_threadsController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText: 'n_threads',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxWidth: 150,
                                              ),
                                              child: Wrap(
                                                children: [
                                                  const Text(
                                                    'n_predict:',
                                                  ),
                                                  TextField(
                                                    controller: paramsLlama
                                                        .n_predictController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText: 'n_predict',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxWidth: 150,
                                              ),
                                              child: Wrap(
                                                children: [
                                                  const Text(
                                                    'repeat_last_n:',
                                                  ),
                                                  TextField(
                                                    controller: paramsLlama
                                                        .repeat_last_nController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText: 'repeat_last_n',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxWidth: 150,
                                              ),
                                              child: Wrap(
                                                children: [
                                                  const Text(
                                                    'n_parts (-1 for auto):',
                                                  ),
                                                  TextField(
                                                    controller: paramsLlama
                                                        .n_partsController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText: 'n_parts',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxWidth: 150,
                                              ),
                                              child: Wrap(
                                                children: [
                                                  const Text(
                                                    'n_ctx:',
                                                  ),
                                                  TextField(
                                                    controller: paramsLlama
                                                        .n_ctxController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText: 'n_ctx',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxWidth: 150,
                                              ),
                                              child: Wrap(
                                                children: [
                                                  const Text(
                                                    'top_k:',
                                                  ),
                                                  TextField(
                                                    controller: paramsLlama
                                                        .top_kController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText: 'top_k',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxWidth: 150,
                                              ),
                                              child: Wrap(
                                                children: [
                                                  const Text(
                                                    'top_p:',
                                                  ),
                                                  TextField(
                                                    controller: paramsLlama
                                                        .top_pController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText: 'top_p',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxWidth: 150,
                                              ),
                                              child: Wrap(
                                                children: [
                                                  const Text(
                                                    'temp:',
                                                  ),
                                                  TextField(
                                                    controller: paramsLlama
                                                        .tempController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText: 'temp',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxWidth: 150,
                                              ),
                                              child: Wrap(
                                                children: [
                                                  const Text(
                                                    'repeat_penalty:',
                                                  ),
                                                  TextField(
                                                    controller: paramsLlama
                                                        .repeat_penaltyController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText:
                                                          'repeat_penalty',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxWidth: 150,
                                              ),
                                              child: Wrap(
                                                children: [
                                                  const Text(
                                                    'batch_size:',
                                                  ),
                                                  TextField(
                                                    controller: paramsLlama
                                                        .n_batchController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText: 'batch_size',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxWidth: 150,
                                              ),
                                              child: Wrap(
                                                alignment: WrapAlignment.center,
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                children: [
                                                  const Text(
                                                    'memory_f16:',
                                                  ),
                                                  Checkbox(
                                                      value: paramsLlama
                                                          .memory_f16,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          paramsLlama
                                                                  .memory_f16 =
                                                              value!;
                                                        });
                                                        paramsLlama
                                                            .saveBoolToSharedPrefs(
                                                                'memory_f16',
                                                                value!);
                                                      }),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxWidth: 150,
                                              ),
                                              child: Wrap(
                                                alignment: WrapAlignment.center,
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                children: [
                                                  const Text(
                                                    'random_prompt:',
                                                  ),
                                                  Checkbox(
                                                      value: paramsLlama
                                                          .random_prompt,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          paramsLlama
                                                                  .random_prompt =
                                                              value!;
                                                        });
                                                        paramsLlama
                                                            .saveBoolToSharedPrefs(
                                                                'random_prompt',
                                                                value!);
                                                      }),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxWidth: 150,
                                              ),
                                              child: Wrap(
                                                alignment: WrapAlignment.center,
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                children: [
                                                  const Text(
                                                    'interactive:',
                                                  ),
                                                  Checkbox(
                                                      value: paramsLlama
                                                          .interactive,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          paramsLlama
                                                                  .interactive =
                                                              value!;
                                                        });
                                                        paramsLlama
                                                            .saveBoolToSharedPrefs(
                                                                'interactive',
                                                                value!);
                                                      }),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxWidth: 150,
                                              ),
                                              child: Wrap(
                                                alignment: WrapAlignment.center,
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                children: [
                                                  const Text(
                                                    'interactive_start:',
                                                  ),
                                                  Checkbox(
                                                      value: paramsLlama
                                                          .interactive_start,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          paramsLlama
                                                                  .interactive_start =
                                                              value!;
                                                        });
                                                        paramsLlama
                                                            .saveBoolToSharedPrefs(
                                                                'interactive_start',
                                                                value!);
                                                      }),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxWidth: 150,
                                              ),
                                              child: Wrap(
                                                alignment: WrapAlignment.center,
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                children: [
                                                  const Text(
                                                    'instruct (Chat4all and Alpaca):',
                                                  ),
                                                  Checkbox(
                                                      value:
                                                          paramsLlama.instruct,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          paramsLlama.instruct =
                                                              value!;
                                                        });
                                                        paramsLlama
                                                            .saveBoolToSharedPrefs(
                                                                'instruct',
                                                                value!);
                                                      }),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxWidth: 150,
                                              ),
                                              child: Wrap(
                                                alignment: WrapAlignment.center,
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                children: [
                                                  const Text(
                                                    'ignore_eos:',
                                                  ),
                                                  Checkbox(
                                                      value: paramsLlama
                                                          .ignore_eos,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          paramsLlama
                                                                  .ignore_eos =
                                                              value!;
                                                        });
                                                        paramsLlama
                                                            .saveBoolToSharedPrefs(
                                                                'ignore_eos',
                                                                value!);
                                                      }),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxWidth: 150,
                                              ),
                                              child: Wrap(
                                                alignment: WrapAlignment.center,
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                children: [
                                                  const Text(
                                                    'perplexity:',
                                                  ),
                                                  Checkbox(
                                                      value: paramsLlama
                                                          .perplexity,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          paramsLlama
                                                                  .perplexity =
                                                              value!;
                                                        });
                                                        paramsLlama
                                                            .saveBoolToSharedPrefs(
                                                                'perplexity',
                                                                value!);
                                                      }),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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
                              controller: promptController,
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
                                        onPressed: (inProgress) ? null : _exec,
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 5),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (!inProgress)
                                              const Icon(
                                                Icons.send_sharp,
                                                color: Colors.white,
                                              ),
                                            if (inProgress)
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
                                      if (canStop && inProgress)
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
                      if (fileState == FileState.opening)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: const [
                                Text(
                                  "Opening file...\nPlease wait a minute...",
                                  textAlign: TextAlign.center,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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

enum FileState {
  notFound,
  found,
  opening,
}

class ParamsLlama {
  bool memory_f16 = false; // use f16 instead of f32 for memory kv
  bool random_prompt = false; // do not randomize prompt if none provided
  bool use_color = false; // use color to distinguish generations and inputs
  bool interactive = true; // interactive mode
  bool interactive_start = false; // wait for user input immediately
  bool instruct = true; // instruction mode (used for Alpaca models)
  bool ignore_eos = false; // do not stop generating after eos
  bool perplexity = false;

  TextEditingController seedController = TextEditingController()..text = "-1";
  TextEditingController n_threadsController = TextEditingController()
    ..text = "4";
  TextEditingController n_predictController = TextEditingController()
    ..text = "512";
  TextEditingController repeat_last_nController = TextEditingController()
    ..text = "64";
  TextEditingController n_partsController = TextEditingController()
    ..text = "-1";
  TextEditingController n_ctxController = TextEditingController()..text = "512";
  TextEditingController top_kController = TextEditingController()..text = "40";
  TextEditingController top_pController = TextEditingController()..text = "0.9";
  TextEditingController tempController = TextEditingController()..text = "0.80";
  TextEditingController repeat_penaltyController = TextEditingController()
    ..text = "1.10";
  TextEditingController n_batchController = TextEditingController()..text = "8";

  ParamsLlama() {
    initFromSharedPrefs();
    addListeners();
  }

  void initFromSharedPrefs() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("memory_f16")) {
      memory_f16 = prefs.getBool("memory_f16")!;
    }
    if (prefs.containsKey("random_prompt")) {
      random_prompt = prefs.getBool("random_prompt")!;
    }
    if (prefs.containsKey("use_color")) {
      use_color = prefs.getBool("use_color")!;
    }
    if (prefs.containsKey("interactive")) {
      interactive = prefs.getBool("interactive")!;
    }
    if (prefs.containsKey("interactive_start")) {
      interactive_start = prefs.getBool("interactive_start")!;
    }
    if (prefs.containsKey("instruct")) {
      instruct = prefs.getBool("instruct")!;
    }
    if (prefs.containsKey("ignore_eos")) {
      ignore_eos = prefs.getBool("ignore_eos")!;
    }
    if (prefs.containsKey("perplexity")) {
      perplexity = prefs.getBool("perplexity")!;
    }
    if (prefs.containsKey("seed")) {
      seedController.text = prefs.getString("seed")!;
    }
    if (prefs.containsKey("n_threads")) {
      n_threadsController.text = prefs.getString("n_threads")!;
    }
    if (prefs.containsKey("n_predict")) {
      n_predictController.text = prefs.getString("n_predict")!;
    }
    if (prefs.containsKey("repeat_last_n")) {
      repeat_last_nController.text = prefs.getString("repeat_last_n")!;
    }
    if (prefs.containsKey("n_parts")) {
      n_partsController.text = prefs.getString("n_parts")!;
    }
    if (prefs.containsKey("n_ctx")) {
      n_ctxController.text = prefs.getString("n_ctx")!;
    }
    if (prefs.containsKey("top_k")) {
      top_kController.text = prefs.getString("top_k")!;
    }
    if (prefs.containsKey("top_p")) {
      top_pController.text = prefs.getString("top_p")!;
    }
    if (prefs.containsKey("temp")) {
      tempController.text = prefs.getString("temp")!;
    }
    if (prefs.containsKey("repeat_penalty")) {
      repeat_penaltyController.text = prefs.getString("repeat_penalty")!;
    }
    if (prefs.containsKey("n_batch")) {
      n_batchController.text = prefs.getString("n_batch")!;
    }
  }

  void addListeners() {
    seedController.addListener(() {
      saveStringToSharedPrefs("seed", seedController.text);
    });
    n_threadsController.addListener(() {
      saveStringToSharedPrefs("n_threads", n_threadsController.text);
    });
    n_predictController.addListener(() {
      saveStringToSharedPrefs("n_predict", n_predictController.text);
    });
    repeat_last_nController.addListener(() {
      saveStringToSharedPrefs("repeat_last_n", repeat_last_nController.text);
    });
    n_partsController.addListener(() {
      saveStringToSharedPrefs("n_parts", n_partsController.text);
    });
    n_ctxController.addListener(() {
      saveStringToSharedPrefs("n_ctx", n_ctxController.text);
    });
    top_kController.addListener(() {
      saveStringToSharedPrefs("top_k", top_kController.text);
    });
    top_pController.addListener(() {
      saveStringToSharedPrefs("top_p", top_pController.text);
    });
    tempController.addListener(() {
      saveStringToSharedPrefs("temp", tempController.text);
    });
    repeat_penaltyController.addListener(() {
      saveStringToSharedPrefs("repeat_penalty", repeat_penaltyController.text);
    });
    n_batchController.addListener(() {
      saveStringToSharedPrefs("n_batch", n_batchController.text);
    });
  }

  void saveStringToSharedPrefs(String s, String text) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(s, text);
    });
  }

  void saveBoolToSharedPrefs(String s, bool value) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(s, value);
    });
  }

  void resetAll(void Function(VoidCallback fn) setState) async {
    setState(() {
      memory_f16 = false;
      random_prompt = false;
      use_color = false;
      interactive = true;
      interactive_start = false;
      instruct = true;
      ignore_eos = false;
      perplexity = false;
    });

    seedController.text = "-1";
    n_threadsController.text = "4";
    n_predictController.text = "512";
    repeat_last_nController.text = "64";
    n_partsController.text = "-1";
    n_ctxController.text = "512";
    top_kController.text = "40";
    top_pController.text = "0.9";
    tempController.text = "0.80";
    repeat_penaltyController.text = "1.10";
    n_batchController.text = "8";
    saveAll();
  }

  void saveAll() {
    saveBoolToSharedPrefs("memory_f16", memory_f16);
    saveBoolToSharedPrefs("random_prompt", random_prompt);
    saveBoolToSharedPrefs("use_color", use_color);
    saveBoolToSharedPrefs("interactive", interactive);
    saveBoolToSharedPrefs("interactive_start", interactive_start);
    saveBoolToSharedPrefs("instruct", instruct);
    saveBoolToSharedPrefs("ignore_eos", ignore_eos);
    saveBoolToSharedPrefs("perplexity", perplexity);
    saveStringToSharedPrefs("seed", seedController.text);
    saveStringToSharedPrefs("n_threads", n_threadsController.text);
    saveStringToSharedPrefs("n_predict", n_predictController.text);
    saveStringToSharedPrefs("repeat_last_n", repeat_last_nController.text);
    saveStringToSharedPrefs("n_parts", n_partsController.text);
    saveStringToSharedPrefs("n_ctx", n_ctxController.text);
    saveStringToSharedPrefs("top_k", top_kController.text);
    saveStringToSharedPrefs("top_p", top_pController.text);
    saveStringToSharedPrefs("temp", tempController.text);
    saveStringToSharedPrefs("repeat_penalty", repeat_penaltyController.text);
    saveStringToSharedPrefs("n_batch", n_batchController.text);
  }
}

class ParamsLlamaValuesOnly {
  bool memory_f16;
  bool random_prompt;
  bool use_color;
  bool interactive;
  bool interactive_start;
  bool instruct;
  bool ignore_eos;
  bool perplexity;
  String seed;
  String n_threads;
  String n_predict;
  String repeat_last_n;
  String n_parts;
  String n_ctx;
  String top_k;
  String top_p;
  String temp;
  String repeat_penalty;
  String n_batch;

  ParamsLlamaValuesOnly({
    required this.memory_f16,
    required this.random_prompt,
    required this.use_color,
    required this.interactive,
    required this.interactive_start,
    required this.instruct,
    required this.ignore_eos,
    required this.perplexity,
    required this.seed,
    required this.n_threads,
    required this.n_predict,
    required this.repeat_last_n,
    required this.n_parts,
    required this.n_ctx,
    required this.top_k,
    required this.top_p,
    required this.temp,
    required this.repeat_penalty,
    required this.n_batch,
  });
}
