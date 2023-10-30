import 'dart:io';
import 'dart:ffi';
import 'dart:async';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:maid/config/butler_bindings.dart';
import 'package:maid/config/character.dart';
import 'package:maid/config/model.dart';
import 'package:maid/config/settings.dart';

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
      Settings.log(e.toString());
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
    params.ref.model_path = model.parameters["model_path"].toString().toNativeUtf8().cast<Char>();
    params.ref.preprompt = character.getPrePrompt().toNativeUtf8().cast<Char>();
    params.ref.input_prefix = character.userAliasController.text.trim().toNativeUtf8().cast<Char>();
    params.ref.input_suffix = character.responseAliasController.text.trim().toNativeUtf8().cast<Char>();
    params.ref.seed = model.parameters["random_seed"] ? -1 : model.parameters["seed"];
    params.ref.n_ctx = model.parameters["n_ctx"];
    params.ref.n_threads = model.parameters["n_threads"];
    params.ref.n_batch = model.parameters["n_batch"];
    params.ref.n_predict = model.parameters["n_predict"];
    params.ref.instruct = model.parameters["instruct"]       ? 1 : 0;
    params.ref.memory_f16 = model.parameters["memory_f16"]   ? 1 : 0;
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
    params.ref.penalize_nl = model.parameters["penalize_nl"]     ? 1 : 0;

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
        model.busy = false;
        maidOutput("");
      }
    });
    await completer.future;
  }

  void butlerContinue() {
    String input = character.promptController.text;
    print("Input: $input");
    Settings.log("Input: $input");
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