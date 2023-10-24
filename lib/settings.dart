import 'dart:io';
import 'dart:ffi';
import 'dart:async';
import 'dart:isolate';
import 'dart:convert';

import 'package:ffi/ffi.dart';
import 'package:maid/butler.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

Settings settings = Settings();

class Settings { 
  bool inProgress = false;
  bool memory_f16 = false; // use f16 instead of f32 for memory kv
  bool instruct = true;
  bool random_seed = true; // use random seed

  TextEditingController promptController = TextEditingController();

  TextEditingController prePromptController = TextEditingController()..text =
    'A chat between a curious user and an artificial intelligence assistant. '
    'The assistant gives helpful, detailed, and polite answers to the user\'s questions.';
  
  List<TextEditingController> examplePromptControllers = [];
  List<TextEditingController> exampleResponseControllers = [];

  TextEditingController userAliasController = TextEditingController()..text = "USER:";
  TextEditingController responseAliasController = TextEditingController()..text = "ASSISTANT:";

  var params = {};

  String modelName = "";
  String modelPath = "";
  String prePrompt = "";

  int seed = -1;
  int n_ctx = 512;
  int n_batch = 8;
  int n_threads = 4;
  int n_predict = 512;
  int n_keep = 48;

  int n_prev = 64;
  int n_probs = 0;
  int top_k = 40;

  double top_p = 0.95;
  double tfs_z = 1.0;
  double typical_p = 1.0;
  double temperature = 0.8;

  int penalty_last_n = 64;

  double penalty_repeat = 1.1;
  double penalty_freq = 0.0;
  double penalty_present = 0.0;

  int mirostat = 0;

  double mirostat_tau = 5.0;
  double mirostat_eta = 0.1;

  bool penalize_nl = true;

  Settings() {
    initKeys();
    initFromSharedPrefs();
  }

  void initKeys() {
    // Map for parameter values
    params = {
      "instruct": instruct,
      "memory_f16": memory_f16,
      "random_seed": random_seed,
      "penalize_nl": penalize_nl,
      "modelPath": modelPath,
      "modelName": modelName,
      "pre_prompt": prePromptController,
      "user_alias": userAliasController,
      "response_alias": responseAliasController,
      "seed": seed,
      "n_ctx": n_ctx,
      "n_batch": n_batch,
      "n_threads": n_threads,
      "n_predict": n_predict,
      "n_keep": n_keep,
      "n_prev": n_prev,
      "n_probs": n_probs,
      "top_k": top_k,
      "penalty_last_n": penalty_last_n,
      "mirostat": mirostat,
      "top_p": top_p,
      "tfs_z": tfs_z,
      "typical_p": typical_p,
      "temperature": temperature,
      "penalty_repeat": penalty_repeat,
      "penalty_freq": penalty_freq,
      "penalty_present": penalty_present,
      "mirostat_tau": mirostat_tau,
      "mirostat_eta": mirostat_eta,
    };
  }

  void initFromSharedPrefs() async {
    var prefs = await SharedPreferences.getInstance();

    for (var key in params.keys) {
      if (prefs.containsKey(key)) {
        if (params[key] is bool) {
          params[key] = prefs.getBool(key)!;
        } 
        else if (params[key] is TextEditingController) {
          params[key]!.text = prefs.getString(key)!;
        } 
        else if (params[key] is int) {
          params[key] = prefs.getInt(key)!;
        } 
        else if (params[key] is double) {
          params[key] = prefs.getDouble(key)!;
        } 
        else if (params[key] is String) {
          params[key] = prefs.getString(key)!;
        }
      }
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

  void resetAll() async {
    // Reset all the internal state to the defaults
    initKeys();

    inProgress = false;
    memory_f16 = false;
    instruct = true;
    random_seed = true;
    modelName = "";
    modelPath = "";
    prePrompt = "";
    seed = -1;
    n_ctx = 512;
    n_batch = 8;
    n_threads = 4;
    n_predict = 512;
    n_keep = 48;
    n_prev = 64;
    n_probs = 0;
    top_k = 40;
    top_p = 0.95;
    tfs_z = 1.0;
    typical_p = 1.0;
    temperature = 0.8;
    penalty_last_n = 64;
    penalty_repeat = 1.1;
    penalty_freq = 0.0;
    penalty_present = 0.0;
    mirostat = 0;
    mirostat_tau = 5.0;
    mirostat_eta = 0.1;
    penalize_nl = true;

    promptController.clear();
    prePromptController.text =
      'A chat between a curious user and an artificial intelligence assistant. '
      'The assistant gives helpful, detailed, and polite answers to the user\'s questions.';
    examplePromptControllers.clear();
    exampleResponseControllers.clear();
    userAliasController.text = "USER:";
    responseAliasController.text = "ASSISTANT:";

    // Clear values from SharedPreferences
    var prefs = await SharedPreferences.getInstance();
    prefs.clear();

    // It might be a good idea to save the default settings after a reset
    saveSharedPreferences();
  }

  void saveSharedPreferences() async {
    var prefs = await SharedPreferences.getInstance();

    for (var key in params.keys) {
      if (params[key] is bool) {
        prefs.setBool(key, params[key]);
      } 
      else if (params[key] is TextEditingController) {
        prefs.setString(key, params[key]!.text);
      } 
      else if (params[key] is int) {
        prefs.setInt(key, params[key]);
      } 
      else if (params[key] is double) {
        prefs.setDouble(key, params[key]);
      } 
      else if (params[key] is String) {
        prefs.setString(key, params[key]);
      }
    }

    prefs.setInt("exampleCount", examplePromptControllers.length);

    for (var i = 0; i < examplePromptControllers.length; i++) {
      prefs.setString("examplePrompt_$i", examplePromptControllers[i].text);
      prefs.setString("exampleResponse_$i", exampleResponseControllers[i].text);
    }
  }

  Future<String> saveSettingsToJson() async {
    Map<String, dynamic> jsonMap = {};

    // Convert the Settings instance to a map
    for (var key in params.keys) {
      if (params[key] is bool) {
        jsonMap[key] = params[key];
      } 
      else if (params[key] is TextEditingController) {
        jsonMap[key] = params[key]!.text;
      } 
      else if (params[key] is int) {
        jsonMap[key] = params[key];
      } 
      else if (params[key] is double) {
        jsonMap[key] = params[key];
      } 
      else if (params[key] is String) {
        jsonMap[key] = params[key];
      }
    }

    jsonMap['examplePrompts'] = settings.examplePromptControllers.map((e) => e.text).toList();
    jsonMap['exampleResponses'] = settings.exampleResponseControllers.map((e) => e.text).toList();

    // Convert the map to a JSON string
    String jsonString = json.encode(jsonMap);
    String? filePath;

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        Directory? directory;
        if (Platform.isAndroid && (await Permission.manageExternalStorage.request().isGranted)) {
          directory = await Directory('/storage/emulated/0/Download/Maid').create();
        } 
        else if (Platform.isIOS && (await Permission.storage.request().isGranted)) {
          directory = await getDownloadsDirectory();
        } else {
          return "Permission Request Failed";
        }

        filePath = '${directory!.path}/maid_settings.json';
      }
      else {
        filePath = await FilePicker.platform.saveFile(type: FileType.any);
      }

      if (filePath != null) {
        File file = File(filePath);
        await file.writeAsString(jsonString);
      } else {
        return "No File Selected";
      }
    } catch (e) {
      return "Error: $e";
    }
    return "Settings Successfully Saved to $filePath";
  }

  Future<String> loadSettingsFromJson() async {
    if ((Platform.isAndroid || Platform.isIOS) && 
        !(await Permission.storage.request().isGranted)) {
      return "Permission Request Failed";
    }
    
    try{
      final result = await FilePicker.platform.pickFiles(type: FileType.any);

      if (result != null) {
        File file = File(result.files.single.path!);
        String jsonString = await file.readAsString();

        Map<String, dynamic> jsonMap = json.decode(jsonString);

        // Update the Settings instance from the map
        for (var key in jsonMap.keys) {
          if (params.containsKey(key)) {
            if (params[key] is bool) {
              params[key] = jsonMap[key];
            } else if (params[key] is TextEditingController) {
              params[key]!.text = jsonMap[key];
            } else if (params[key] is int) {
              params[key] = jsonMap[key];
            } else if (params[key] is double) {
              params[key] = jsonMap[key];
            } else if (params[key] is String) {
              params[key] = jsonMap[key];
            }
          }
        }

        for (var i = 0; i < jsonMap['examplePrompts'].length; i++) {
          settings.examplePromptControllers[i].text = jsonMap['examplePrompts'][i];
          settings.exampleResponseControllers[i].text = jsonMap['exampleResponses'][i];
        }
      }
    } catch (e) {
      return "Error: $e";
    }

    return "Settings Successfully Loaded";
  }

  Future<String> loadModelFile() async {
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
      return "Error: $e";
    }
  
    return "Model Successfully Loaded";
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

  static void _maidOutputBridge(int code, Pointer<Char> buffer) {
    try {
      if (code == return_code.CONTINUE) {
        _sendPort?.send(buffer.cast<Utf8>().toDartString());
      } else if (code == return_code.STOP) {
        _sendPort?.send(code);
      }
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
    params.ref.input_prefix = settings.userAliasController.text.trim().toNativeUtf8().cast<Char>();
    params.ref.input_suffix = settings.responseAliasController.text.trim().toNativeUtf8().cast<Char>();
    params.ref.seed = settings.random_seed ? -1 : settings.seed;
    params.ref.n_ctx = settings.n_ctx;
    params.ref.n_threads = settings.n_threads;
    params.ref.n_batch = settings.n_batch;
    params.ref.n_predict = settings.n_predict;
    params.ref.instruct = settings.instruct           ? 1 : 0;
    params.ref.memory_f16 = settings.memory_f16       ? 1 : 0;
    params.ref.n_prev = settings.n_prev;
    params.ref.n_probs = settings.n_probs;
    params.ref.top_k = settings.top_k;
    params.ref.top_p = settings.top_p;
    params.ref.tfs_z = settings.tfs_z;
    params.ref.typical_p = settings.typical_p;
    params.ref.temp = settings.temperature;
    params.ref.penalty_last_n = settings.penalty_last_n;
    params.ref.penalty_repeat = settings.penalty_repeat;
    params.ref.penalty_freq = settings.penalty_freq;
    params.ref.penalty_present = settings.penalty_present;
    params.ref.mirostat = settings.mirostat;
    params.ref.mirostat_tau = settings.mirostat_tau;
    params.ref.mirostat_eta = settings.mirostat_eta;
    params.ref.penalize_nl = settings.penalize_nl     ? 1 : 0;

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
      } else if (data is int) {
        settings.inProgress = false;
        maidOutput("");
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