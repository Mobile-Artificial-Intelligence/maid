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

Model model = Model();

class Model {
  static const String defaultPreprompt = 
    'A chat between a curious user and an artificial intelligence assistant. '
    'The assistant gives helpful, detailed, and polite answers to the user\'s questions.';
  
  bool inProgress = false;
  bool memory_f16 = false; // use f16 instead of f32 for memory kv
  bool random_prompt = false; // do not randomize prompt if none provided
  bool use_color = false; // use color to distinguish generations and inputs
  bool interactive = true; // interactive mode
  bool interactive_start = false; // wait for user input immediately
  bool instruct = true; // instruction mode (used for Alpaca models)
  bool ignore_eos = false; // do not stop generating after eos
  bool perplexity = false;

  TextEditingController promptController = TextEditingController();
  TextEditingController reversePromptController = TextEditingController();

  TextEditingController prePromptController = TextEditingController()..text = defaultPreprompt;
  
  List<TextEditingController> examplePromptControllers = [];
  List<TextEditingController> exampleResponseControllers = [];

  TextEditingController userAliasController = TextEditingController()..text = "USER:";
  TextEditingController responseAliasController = TextEditingController()..text = "ASSISTANT:";

  TextEditingController seedController = TextEditingController()..text = "-1";
  TextEditingController n_threadsController = TextEditingController()..text = "4";
  TextEditingController n_predictController = TextEditingController()..text = "512";
  TextEditingController repeat_last_nController = TextEditingController()..text = "64";
  TextEditingController n_partsController = TextEditingController()..text = "-1";
  TextEditingController n_ctxController = TextEditingController()..text = "512";
  TextEditingController top_kController = TextEditingController()..text = "40";
  TextEditingController top_pController = TextEditingController()..text = "0.9";
  TextEditingController tempController = TextEditingController()..text = "0.80";
  TextEditingController repeat_penaltyController = TextEditingController()..text = "1.10";
  TextEditingController n_batchController = TextEditingController()..text = "8";

  var boolKeys = {};
  var stringKeys = {};

  String modelName = "";
  String modelPath = "";
  String prePrompt = "";

  Model() {
    initKeys();
    initFromSharedPrefs();
    addListeners();
  }

  void initKeys() {
    // Map for boolean values
    boolKeys = {
      "memory_f16": memory_f16,
      "random_prompt": random_prompt,
      "use_color": use_color,
      "interactive": interactive,
      "interactive_start": interactive_start,
      "instruct": instruct,
      "ignore_eos": ignore_eos,
      "perplexity": perplexity
    };

    // Map for string values
    stringKeys = {
      "pre_prompt": prePromptController,
      "seed": seedController,
      "n_threads": n_threadsController,
      "n_predict": n_predictController,
      "repeat_last_n": repeat_last_nController,
      "n_parts": n_partsController,
      "n_ctx": n_ctxController,
      "top_k": top_kController,
      "top_p": top_pController,
      "temp": tempController,
      "repeat_penalty": repeat_penaltyController,
      "n_batch": n_batchController
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
      use_color = false;
      interactive = true;
      interactive_start = false;
      instruct = true;
      ignore_eos = false;
      perplexity = false;
    });

    prePromptController.text = defaultPreprompt;
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
    saveStringToSharedPrefs("modelPath", modelPath);
    saveStringToSharedPrefs("modelName", modelName);
    saveStringToSharedPrefs("pre_prompt", prePromptController.text);
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
  static SendPort? sendPort;
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

  static void _maidOutputBridge(Pointer<Char> output) {
    try {
      sendPort?.send(output.cast<Utf8>().toDartString());
    } catch (e) {
      print(e.toString());
    }
  }

  static butlerContinueIsolate(Map<String, dynamic> args) async {
    sendPort = args['port'] as SendPort?;
    String input = args['input'];
    Pointer<Char> text = input.trim().toNativeUtf8().cast<Char>();
    Lib.instance._nativeLibrary.butler_continue(text, Pointer.fromFunction(_maidOutputBridge));
  }


  void butlerStart(void Function(String) maidOutput) async {
    final params = calloc<butler_params>();
    params.ref.model_path = model.modelPath.toNativeUtf8().cast<Char>();
    params.ref.prompt = model.prePrompt.toNativeUtf8().cast<Char>();
    params.ref.antiprompt = model.reversePromptController.text.trim().toNativeUtf8().cast<Char>();

    _nativeLibrary.butler_start(params);

    ReceivePort receivePort = ReceivePort();
    sendPort = receivePort.sendPort;
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
    String input = model.promptController.text;
    Isolate.spawn(butlerContinueIsolate, {
      'input': input,
      'port': sendPort
    });
  }

  void butlerStop() {
    _nativeLibrary.butler_stop();
  }

  void butlerExit() {
    _nativeLibrary.butler_exit();
    sendPort?.send(sendPort);
  }
}