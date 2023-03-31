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

  var promptController = TextEditingController();

  final ScrollController _consoleScrollController = ScrollController();

  String prePrompt = "";

  List<String> defaultPrePrompts = [
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

  toggleShowLog() {
    setState(() {
      showLog = !showLog;
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

  void done() {
    setState(() {
      inProgress = false;
    });
  }

  void _exec() {
    //close the keyboard
    FocusScope.of(context).unfocus();
    setState(() {
      inProgress = true;
    });
    if (lib == null) {
      lib = Lib();
      lib?.executeBinary(
        printLnLog: printLnLog,
        printLog: printResult,
        promptPassed: prePrompt +
            promptController.text.trim() +
            (promptController.text.isEmpty ? "" : "\n"),
        done: done,
        stopToken: reversePromptController.text,
      );
    } else {
      lib?.newPromp(" " +
          promptController.text.trim() +
          (promptController.text.isEmpty ? "" : "\n"));
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
    if (prePrompts.isNotEmpty) {
      setState(() {
        prePrompt = prePrompts[0];
      });
    }
    reversePromptController.text = 'User :';
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
    //test if the ggml-model.bin file is present
    // if (!File("assets/ggml-model.bin").existsSync()) {
    //   return Scaffold(
    //     appBar: AppBar(
    //       title: const Text("LLaMA"),
    //     ),
    //     body: const Center(
    //       child: Text("ggml-model.bin file not found"),
    //     ),
    //   );
    // }
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
                    //textInputPrompt

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
                                          await ModelFilePath.deleteModelFile();
                                          setState(() {
                                            fileState = FileState.notFound;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          padding: const EdgeInsets.all(0.0),
                                        ),
                                        child: const Text(
                                          "X",
                                          style: TextStyle(color: Colors.white),
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
                                          padding: const EdgeInsets.all(0.0),
                                        ),
                                        child: const Text(
                                          "X",
                                          style: TextStyle(color: Colors.white),
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
                      ElevatedButton(
                        onPressed: toggleShowLog,
                        child: Text(
                          showLog ? "Hide Log" : "Show Log",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      if (showLog)
                        Container(
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
                                            padding: const EdgeInsets.all(8.0),
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
                          constraints: const BoxConstraints(
                            maxHeight: 200,
                          ),
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
                                      border: Border.all(color: Colors.black),
                                      borderRadius: BorderRadius.circular(5),
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
                                Clipboard.setData(ClipboardData(text: result));
                                //delete the toast if it is already present
                                ScaffoldMessenger.of(context)
                                    .removeCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Text copied to clipboard"),
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
                          maxLines: 3,
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
                              child: ElevatedButton(
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
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
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
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _exec,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}

enum FileState {
  notFound,
  found,
  opening,
}
