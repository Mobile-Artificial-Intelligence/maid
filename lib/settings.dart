import 'dart:io';
import 'dart:ffi';
import 'dart:async';
import 'dart:isolate';
import 'dart:convert';

import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:maid/butler.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

Parameters parameters = Parameters();

class Parameters { 
  Map<String, dynamic> parameters = {};

  bool busy = false;

  TextEditingController promptController = TextEditingController();

  TextEditingController prePromptController = TextEditingController();
  
  List<TextEditingController> examplePromptControllers = [];
  List<TextEditingController> exampleResponseControllers = [];

  TextEditingController userAliasController = TextEditingController();
  TextEditingController responseAliasController = TextEditingController();

  late String prePrompt;
  late String modelPath;

  Parameters() {
    initFromSharedPrefs();
  }

  void initFromSharedPrefs() async {
    var prefs = await SharedPreferences.getInstance();

    parameters = json.decode(prefs.getString("parameters") ?? "{}");

    if (parameters.isEmpty) {
      resetAll();
    }

    modelPath = parameters["modelPath"] ?? "";

    prePromptController.text = parameters["prePrompt"] ?? "";
    userAliasController.text = parameters["userAlias"] ?? "";
    responseAliasController.text = parameters["responseAlias"] ?? "";

    int length = parameters["examplePrompt"]?.length ?? 0;
    for (var i = 0; i < length; i++) {
      String? examplePrompt = parameters["examplePrompt_$i"];
      String? exampleResponse = parameters["exampleResponse_$i"];
      if (examplePrompt != null && exampleResponse != null) {
        examplePromptControllers.add(TextEditingController(text: examplePrompt));
        exampleResponseControllers.add(TextEditingController(text: exampleResponse));
      }
    }
  }

  void resetAll() async {
    // Reset all the internal state to the defaults
    String jsonString = await rootBundle.loadString('assets/default_parameters.json');

    parameters = json.decode(jsonString);

    prePromptController.text = parameters["prePrompt"] ?? "";
    userAliasController.text = parameters["userAlias"] ?? "";
    responseAliasController.text = parameters["responseAlias"] ?? "";

    int length = parameters["examplePrompt"]?.length ?? 0;
    for (var i = 0; i < length; i++) {
      String? examplePrompt = parameters["examplePrompt"][i];
      String? exampleResponse = parameters["exampleResponse"][i];
      if (examplePrompt != null && exampleResponse != null) {
        examplePromptControllers.add(TextEditingController(text: examplePrompt));
        exampleResponseControllers.add(TextEditingController(text: exampleResponse));
      }
    }

    // Clear values from SharedPreferences
    var prefs = await SharedPreferences.getInstance();
    prefs.clear();

    // It might be a good idea to save the default parameters after a reset
    saveSharedPreferences();
  }

  void saveSharedPreferences() async {
    parameters["modelPath"] = modelPath;
    parameters["prePrompt"] = prePromptController.text;
    parameters["userAlias"] = userAliasController.text;
    parameters["responseAlias"] = responseAliasController.text;

    for (var i = 0; i < examplePromptControllers.length; i++) {
      parameters["examplePrompt"][i] = examplePromptControllers[i].text;
      parameters["exampleResponse"][i] = exampleResponseControllers[i].text;
    }
    
    var prefs = await SharedPreferences.getInstance();

    prefs.setString("parameters", json.encode(parameters));
  }

  Future<String> saveParametersToJson() async {
    parameters["modelPath"] = modelPath;
    parameters["prePrompt"] = prePromptController.text;
    parameters["userAlias"] = userAliasController.text;
    parameters["responseAlias"] = responseAliasController.text;

    for (var i = 0; i < examplePromptControllers.length; i++) {
      parameters["examplePrompt"][i] = examplePromptControllers[i].text;
      parameters["exampleResponse"][i] = exampleResponseControllers[i].text;
    }

    // Convert the map to a JSON string
    String jsonString = json.encode(parameters);
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

        filePath = '${directory!.path}/maid_parameters.json';
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
    return "Parameters Successfully Saved to $filePath";
  }

  Future<String> loadParametersFromJson() async {
    if ((Platform.isAndroid || Platform.isIOS) && 
        !(await Permission.storage.request().isGranted)) {
      return "Permission Request Failed";
    }
    
    try{
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result == null) return "No File Selected";

      File file = File(result.files.single.path!);
      String jsonString = await file.readAsString();
      if (jsonString.isEmpty) return "Failed to load parameters";
      
      parameters = json.decode(jsonString);
      if (parameters.isEmpty) {
        resetAll();
        return "Failed to decode parameters";
      }

      modelPath = parameters['modelPath'];
      prePromptController.text = parameters['prePrompt'];
      userAliasController.text = parameters['userAlias'];
      responseAliasController.text = parameters['responseAlias'];

      for (var i = 0; i < parameters['examplePrompts'].length; i++) {
        examplePromptControllers[i].text = parameters['examplePrompts'][i];
        exampleResponseControllers[i].text = parameters['exampleResponses'][i];
      }
    } catch (e) {
      resetAll();
      return "Error: $e";
    }

    return "Parameters Successfully Loaded";
  }

  Future<String> loadModelFile() async {
    if ((Platform.isAndroid || Platform.isIOS)) {
      if (!(await Permission.storage.request().isGranted)) {
        return "Permission Request Failed";
      }

      if (modelPath.isNotEmpty) await FilePicker.platform.clearTemporaryFiles();
    }
  
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: "Select Model File",
        type: FileType.any,
        allowMultiple: false,
        onFileLoading: (FilePickerStatus status) => busy = status == FilePickerStatus.picking
      );
      final filePath = result?.files.single.path;
  
      if (filePath == null) {
        return "Failed to load model";
      }
      
      modelPath = filePath;
      parameters["modelName"] = path.basename(filePath);
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
  bool _hasStarted = false;
  bool hasStarted() => _hasStarted;

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
    if (_hasStarted) {
      butlerExit();
      await Future.delayed(const Duration(seconds: 1));
    }
    
    _hasStarted = true;
    
    final params = calloc<butler_params>();
    params.ref.model_path = parameters.modelPath.toNativeUtf8().cast<Char>();
    params.ref.preprompt = parameters.prePrompt.toNativeUtf8().cast<Char>();
    params.ref.input_prefix = parameters.userAliasController.text.trim().toNativeUtf8().cast<Char>();
    params.ref.input_suffix = parameters.responseAliasController.text.trim().toNativeUtf8().cast<Char>();
    params.ref.seed = parameters.parameters["random_seed"] ? -1 : parameters.parameters["seed"];
    params.ref.n_ctx = parameters.parameters["n_ctx"];
    params.ref.n_threads = parameters.parameters["n_threads"];
    params.ref.n_batch = parameters.parameters["n_batch"];
    params.ref.n_predict = parameters.parameters["n_predict"];
    params.ref.instruct = parameters.parameters["instruct"]       ? 1 : 0;
    params.ref.memory_f16 = parameters.parameters["memory_f16"]   ? 1 : 0;
    params.ref.n_prev = parameters.parameters["n_prev"];
    params.ref.n_probs = parameters.parameters["n_probs"];
    params.ref.top_k = parameters.parameters["top_k"];
    params.ref.top_p = parameters.parameters["top_p"];
    params.ref.tfs_z = parameters.parameters["tfs_z"];
    params.ref.typical_p = parameters.parameters["typical_p"];
    params.ref.temp = parameters.parameters["temperature"];
    params.ref.penalty_last_n = parameters.parameters["penalty_last_n"];
    params.ref.penalty_repeat = parameters.parameters["penalty_repeat"];
    params.ref.penalty_freq = parameters.parameters["penalty_freq"];
    params.ref.penalty_present = parameters.parameters["penalty_present"];
    params.ref.mirostat = parameters.parameters["mirostat"];
    params.ref.mirostat_tau = parameters.parameters["mirostat_tau"];
    params.ref.mirostat_eta = parameters.parameters["mirostat_eta"];
    params.ref.penalize_nl = parameters.parameters["penalize_nl"]     ? 1 : 0;

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
        parameters.busy = false;
        maidOutput("");
      }
    });
    await completer.future;
  }

  void butlerContinue() {
    String input = parameters.promptController.text;
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
    _hasStarted = false;
  }
}