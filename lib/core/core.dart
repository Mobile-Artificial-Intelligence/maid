import 'dart:io';
import 'dart:ffi';
import 'dart:async';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:maid/core/bindings.dart';
import 'package:maid/config/character.dart';
import 'package:maid/config/model.dart';
import 'package:maid/config/settings.dart';

class Core {
  static SendPort? _sendPort;
  late NativeLibrary _nativeLibrary;

  // Make the default constructor private
  Core._();

  // Private reference to the global instance
  static final Core _instance = Core._();

  // Public accessor to the global instance
  static Core get instance {
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
    DynamicLibrary coreDynamic =
      Platform.isMacOS || Platform.isIOS
        ? DynamicLibrary.process() // macos and ios
        : (DynamicLibrary.open(
          Platform.isWindows // windows
            ? 'core.dll'
            : 'libcore.so')); // android and linux

    _nativeLibrary = NativeLibrary(coreDynamic);
  }

  static void _maidOutputBridge(int code, Pointer<Char> buffer) {
    try {
      if (code == return_code.CONTINUE) {
        _sendPort?.send(buffer.cast<Utf8>().toDartString());
      } else if (code == return_code.STOP) {
        _sendPort?.send(code);
      }
    } catch (e) {
      Logger.log(e.toString());
    }
  }

  static promptIsolate(Map<String, dynamic> args) async {
    _sendPort = args['port'] as SendPort?;
    String input = args['input'];
    Pointer<Char> text = input.trim().toNativeUtf8().cast<Char>();
    Core.instance._nativeLibrary.core_prompt(text, Pointer.fromFunction(_maidOutputBridge));
  }


  void init(String input, void Function(String) maidOutput) async {
    if (_hasStarted) {
      cleanup();
      await Future.delayed(const Duration(seconds: 1));
    }
    
    _hasStarted = true;
    
    final params = calloc<maid_params>();
    params.ref.model_path = model.parameters["model_path"].toString().toNativeUtf8().cast<Char>();
    params.ref.preprompt = character.getPrePrompt().toNativeUtf8().cast<Char>();
    params.ref.input_prefix = character.userAliasController.text.trim().toNativeUtf8().cast<Char>();
    params.ref.input_suffix = character.responseAliasController.text.trim().toNativeUtf8().cast<Char>();
    params.ref.seed = model.parameters["random_seed"] ? -1 : model.parameters["seed"];
    params.ref.n_ctx = model.parameters["n_ctx"];
    params.ref.n_threads = model.parameters["n_threads"];
    params.ref.n_batch = model.parameters["n_batch"];
    params.ref.n_predict = model.parameters["n_predict"];
    params.ref.instruct = model.parameters["instruct"]              ? 1 : 0;
    params.ref.interactive = model.parameters["interactive"]        ? 1 : 0;
    params.ref.memory_f16 = model.parameters["memory_f16"]          ? 1 : 0;
    params.ref.n_prev = model.parameters["n_prev"];
    params.ref.n_probs = model.parameters["n_probs"];
    params.ref.top_k = model.parameters["top_k"];
    params.ref.top_p = model.parameters["top_p"];
    params.ref.tfs_z = model.parameters["tfs_z"];
    params.ref.typical_p = model.parameters["typical_p"];
    params.ref.temp = model.parameters["temperature"];
    params.ref.penalty_last_n = model.parameters["penalty_last_n"];
    params.ref.penalty_repeat = model.parameters["penalty_repeat"];
    params.ref.penalty_freq = model.parameters["penalty_freq"];
    params.ref.penalty_present = model.parameters["penalty_present"];
    params.ref.mirostat = model.parameters["mirostat"];
    params.ref.mirostat_tau = model.parameters["mirostat_tau"];
    params.ref.mirostat_eta = model.parameters["mirostat_eta"];
    params.ref.penalize_nl = model.parameters["penalize_nl"]        ? 1 : 0;

    _nativeLibrary.core_init(params);

    ReceivePort receivePort = ReceivePort();
    _sendPort = receivePort.sendPort;
    prompt(input);
  
    Completer completer = Completer();
    receivePort.listen((data) {
      if (data is String) {
        maidOutput(data);
      } else if (data is SendPort) {
        completer.complete();
      } else if (data is int) {
        model.busy = false;
        maidOutput("");
      }
    });
    await completer.future;
  }

  void prompt(String input) {
    Logger.log("Input: $input");
    Isolate.spawn(promptIsolate, {
      'input': input,
      'port': _sendPort
    });
  }

  void stop() {
    _nativeLibrary.core_stop();
  }

  void cleanup() {
    if (_hasStarted) {
      _nativeLibrary.core_cleanup();
      _sendPort?.send(_sendPort);
    }
    _hasStarted = false;
  }
}