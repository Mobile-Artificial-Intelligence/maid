import 'dart:io';
import 'dart:ffi';
import 'dart:async';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:maid/butler.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

Settings settings = Settings();

class Settings {
  static const String defaultPreprompt = 
    'A chat between a curious user and an artificial intelligence assistant. '
    'The assistant gives helpful, detailed, and polite answers to the user\'s questions.';
  
  bool inProgress = false;
  bool memory_f16 = false; // use f16 instead of f32 for memory kv
  bool random_prompt = false; // do not randomize prompt if none provided
  bool interactive = true; // interactive mode
  bool interactive_start = false; // wait for user input immediately
  bool instruct = true; // instruction mode (used for Alpaca models)
  bool ignore_eos = false; // do not stop generating after eos

  TextEditingController promptController = TextEditingController();
  TextEditingController reversePromptController = TextEditingController();

  TextEditingController prePromptController = TextEditingController()..text = defaultPreprompt;
  
  List<TextEditingController> examplePromptControllers = [];
  List<TextEditingController> exampleResponseControllers = [];

  TextEditingController userAliasController = TextEditingController()..text = "USER:";
  TextEditingController responseAliasController = TextEditingController()..text = "ASSISTANT:";

  TextEditingController seedController = TextEditingController()..text = "-1";
  TextEditingController n_ctxController = TextEditingController()..text = "512";
  TextEditingController n_batchController = TextEditingController()..text = "8";
  TextEditingController n_threadsController = TextEditingController()..text = "4";
  TextEditingController n_predictController = TextEditingController()..text = "512";

  var boolKeys = {};
  var stringKeys = {};

  String modelName = "";
  String modelPath = "";
  String prePrompt = "";

  Settings() {
    initKeys();
    initFromSharedPrefs();
    addListeners();
  }

  void initKeys() {
    // Map for boolean values
    boolKeys = {
      "memory_f16": memory_f16,
      "random_prompt": random_prompt,
      "interactive": interactive,
      "interactive_start": interactive_start,
      "instruct": instruct,
      "ignore_eos": ignore_eos,
    };

    // Map for string values
    stringKeys = {
      "pre_prompt": prePromptController,
      "user_alias": userAliasController,
      "response_alias": responseAliasController,
      "seed": seedController,
      "n_ctx": n_ctxController,
      "n_batch": n_batchController,
      "n_threads": n_threadsController,
      "n_predict": n_predictController,
    };
  }

  void initFromSharedPrefs() async {
    var prefs = await SharedPreferences.getInstance();

    // Load boolean values from prefs
    for (var key in boolKeys.keys) {
      if (prefs.containsKey(key)) {
        boolKeys[key] = prefs.getBool(key)!;
      }
    }

    // Load string values from prefs
    for (var key in stringKeys.keys) {
      if (prefs.containsKey(key)) {
        stringKeys[key]!.text = prefs.getString(key)!;
      }
    }

    if (prefs.containsKey("modelPath")) {
      modelPath = prefs.getString("modelPath")!;
      modelName = prefs.getString("modelName")!;
    }

    // Load example prompts and responses from prefs
    int exampleCount = prefs.getInt("exampleCount") ?? 0; 
    for (var i = 0; i < exampleCount; i++) {
      String? examplePrompt = prefs.getString("examplePrompt_$i");
      String? exampleResponse = prefs.getString("exampleResponse_$i");
      if (examplePrompt != null && exampleResponse != null) {
        examplePromptControllers.add(TextEditingController(text: examplePrompt));
        exampleResponseControllers.add(TextEditingController(text: exampleResponse));
      }
    }
  }

  void addListeners() {
    stringKeys.forEach((key, controller) {
      controller.addListener(() {
        saveStringToSharedPrefs(key, controller.text);
      });
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

  void saveExamplePromptsAndResponses() {
    SharedPreferences.getInstance().then((prefs) {
      // Store the count of examples
      prefs.setInt("exampleCount", examplePromptControllers.length);
      for (var i = 0; i < examplePromptControllers.length; i++) {
        prefs.setString("examplePrompt_$i", examplePromptControllers[i].text);
        prefs.setString("exampleResponse_$i", exampleResponseControllers[i].text);
      }
    });
  }

  void resetAll(void Function(VoidCallback fn) setState) async {
    setState(() {
      memory_f16 = false;
      random_prompt = false;
      interactive = true;
      interactive_start = false;
      instruct = true;
      ignore_eos = false;
    });

    prePromptController.text = defaultPreprompt;
    seedController.text = "-1";
    n_ctxController.text = "512";
    n_threadsController.text = "4";
    n_predictController.text = "512";
    n_batchController.text = "8";
    saveAll();
  }

  void saveAll() {
    saveBoolToSharedPrefs("memory_f16", memory_f16);
    saveBoolToSharedPrefs("random_prompt", random_prompt);
    saveBoolToSharedPrefs("interactive", interactive);
    saveBoolToSharedPrefs("interactive_start", interactive_start);
    saveBoolToSharedPrefs("instruct", instruct);
    saveBoolToSharedPrefs("ignore_eos", ignore_eos);
    saveStringToSharedPrefs("modelPath", modelPath);
    saveStringToSharedPrefs("modelName", modelName);
    saveStringToSharedPrefs("pre_prompt", prePromptController.text);
    saveStringToSharedPrefs("user_alias", userAliasController.text);
    saveStringToSharedPrefs("response_alias", responseAliasController.text);
    saveStringToSharedPrefs("seed", seedController.text);
    saveStringToSharedPrefs("n_ctx", n_ctxController.text);
    saveStringToSharedPrefs("n_batch", n_batchController.text);
    saveStringToSharedPrefs("n_threads", n_threadsController.text);
    saveStringToSharedPrefs("n_predict", n_predictController.text);
    saveExamplePromptsAndResponses();
  }

  Future<String> openFile() async {
    if ((Platform.isAndroid || Platform.isIOS) && 
        !(await Permission.storage.request().isGranted)) {
      return "Permission Request Failed";
    }
  
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      final filePath = result?.files.single.path;
  
      if (filePath == null) {
        return "Failed to load model";
      }
      
      modelPath = filePath;
      modelName = path.basename(filePath);
    } catch (e) {
      return "Failed to load model";
    }
  
    return "Model Successfully loaded";
  }

  void compilePrePrompt() {
    prePrompt = prePromptController.text.isNotEmpty ? prePromptController.text.trim() : "";
    for (var i = 0; i < examplePromptControllers.length; i++) {
      var prompt = '${userAliasController.text.trim()} ${examplePromptControllers[i].text.trim()}';
      var response = '${responseAliasController.text.trim()} ${exampleResponseControllers[i].text.trim()}';
      if (prompt.isNotEmpty && response.isNotEmpty) {
        prePrompt += "\n$prompt\n$response";
      }
    }
    prePrompt += "\n${userAliasController.text.trim()} ";
  }
}

class Lib {
  static SendPort? _sendPort;
  late NativeLibrary _nativeLibrary;

  // Make the default constructor private
  Lib._();

  // Private reference to the global instance
  static final Lib _instance = Lib._();

  // Public accessor to the global instance
  static Lib get instance {
    _instance._initialize();
    return _instance;
  }

  // Flag to check if the instance has been initialized
  bool _isInitialized = false;

  // Initialization logic
  void _initialize() {
    if (!_isInitialized) {
      _loadNativeLibrary();
      _isInitialized = true;
    }
  }

  void _loadNativeLibrary() {
    DynamicLibrary butlerDynamic =
        Platform.isMacOS || Platform.isIOS
            ? DynamicLibrary.process() // macos and ios
            : (DynamicLibrary.open(
                Platform.isWindows // windows
                    ? 'butler.dll'
                    : 'libbutler.so')); // android and linux

    _nativeLibrary = NativeLibrary(butlerDynamic);
  }

  static void _maidOutputBridge(Pointer<Char> buffer) {
    try {
      _sendPort?.send(buffer.cast<Utf8>().toDartString());
    } catch (e) {
      print(e.toString());
    }
  }

  static butlerContinueIsolate(Map<String, dynamic> args) async {
    _sendPort = args['port'] as SendPort?;
    String input = args['input'];
    Pointer<Char> text = input.trim().toNativeUtf8().cast<Char>();
    Lib.instance._nativeLibrary.butler_continue(text, Pointer.fromFunction(_maidOutputBridge));
  }


  void butlerStart(void Function(String) maidOutput) async {
    final params = calloc<butler_params>();
    params.ref.model_path = settings.modelPath.toNativeUtf8().cast<Char>();
    params.ref.preprompt = settings.prePrompt.toNativeUtf8().cast<Char>();
    params.ref.antiprompt = settings.reversePromptController.text.trim().toNativeUtf8().cast<Char>();
    params.ref.seed = int.tryParse(settings.seedController.text.trim()) ?? -1;
    params.ref.n_ctx = int.tryParse(settings.n_ctxController.text.trim()) ?? 512;
    params.ref.n_threads = int.tryParse(settings.n_threadsController.text.trim()) ?? 4;
    params.ref.n_batch = int.tryParse(settings.n_batchController.text.trim()) ?? 8;

    _nativeLibrary.butler_start(params);

    ReceivePort receivePort = ReceivePort();
    _sendPort = receivePort.sendPort;
    butlerContinue();
  
    Completer completer = Completer();
    receivePort.listen((data) {
      if (data is String) {
        maidOutput(data);
      } else if (data is SendPort) {
        completer.complete();
      }
    });
    await completer.future;
  }

  void butlerContinue() {
        String input = settings.promptController.text;
    Isolate.spawn(butlerContinueIsolate, {
      'input': input,
      'port': _sendPort
    });
  }

  void butlerStop() {
    _nativeLibrary.butler_stop();
      }

  void butlerExit() {
    _nativeLibrary.butler_exit();
    _sendPort?.send(_sendPort);
  }
}