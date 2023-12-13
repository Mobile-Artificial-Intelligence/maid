import 'dart:io';
import 'dart:ffi';
import 'dart:async';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:maid/static/generation_manager.dart';
import 'package:maid/static/logger.dart';
import 'package:maid/core/bindings.dart';
import 'package:maid/types/generation_context.dart';

class LocalGeneration {
  static SendPort? _sendPort;
  late NativeLibrary _nativeLibrary;

  // Make the default constructor private
  LocalGeneration._();

  // Private reference to the global instance
  static final LocalGeneration _instance = LocalGeneration._();

  // Public accessor to the global instance
  static LocalGeneration get instance {
    _instance._initialize();
    return _instance;
  }

  // Flag to check if the instance has been initialized
  bool _isInitialized = false;
  bool _hasStarted = false;

  // Initialization logic
  void _initialize() {
    if (!_isInitialized) {
      _loadNativeLibrary();
      _isInitialized = true;
    }
  }

  void _loadNativeLibrary() {
    DynamicLibrary coreDynamic = DynamicLibrary.process();

    if (Platform.isWindows) coreDynamic = DynamicLibrary.open('core.dll');
    if (Platform.isLinux || Platform.isAndroid) coreDynamic = DynamicLibrary.open('libcore.so');

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

  static _promptIsolate(Map<String, dynamic> args) async {
    _sendPort = args['port'] as SendPort?;
    String input = args['input'];
    Pointer<Char> text = input.trim().toNativeUtf8().cast<Char>();
    LocalGeneration.instance._nativeLibrary
        .core_prompt(text, Pointer.fromFunction(_maidOutputBridge));
  }

  void prompt(
    String input, 
    GenerationContext context,
    void Function(String) callback
  ) async {
    if (_hasStarted) {
      _send(input);
      return;
    }

    try {
      Logger.log(context.toMap().toString());

      _hasStarted = true;

      String preprompt = context.prePrompt;

      if (context.messages.isNotEmpty) {
        for (var i = 0; i < context.messages.length; i++) {
          if (context.messages[i]["role"] == "user") {
            preprompt += "\n${context.userAlias}: ${context.messages[i]["content"].trim()}";
          } else {
            preprompt += "\n${context.responseAlias}: ${context.messages[i]["content"].trim()}";
          }
        }
      }

      final params = calloc<maid_params>();
      params.ref.path = context.path.toString().toNativeUtf8().cast<Char>();
      params.ref.preprompt = preprompt.toNativeUtf8().cast<Char>();
      params.ref.input_prefix =
          context.userAlias.trim().toNativeUtf8().cast<Char>();
      params.ref.input_suffix =
          context.responseAlias.trim().toNativeUtf8().cast<Char>();
      params.ref.seed = context.seed;
      params.ref.n_ctx = context.nCtx;
      params.ref.n_threads = context.nThread;
      params.ref.n_batch = context.nBatch;
      params.ref.n_predict = context.nPredict;
      params.ref.n_keep = context.nKeep;
      params.ref.instruct = context.instruct;
      params.ref.interactive = context.interactive;
      params.ref.chatml = context.chatml;
      params.ref.penalize_nl = context.penalizeNewline;
      params.ref.top_k = context.topK;
      params.ref.top_p = context.topP;
      params.ref.tfs_z = context.tfsZ;
      params.ref.typical_p = context.typicalP;
      params.ref.temp = context.temperature;
      params.ref.penalty_last_n = context.penaltyLastN;
      params.ref.penalty_repeat = context.penaltyRepeat;
      params.ref.penalty_freq = context.penaltyFreq;
      params.ref.penalty_present = context.penaltyPresent;
      params.ref.mirostat = context.mirostat;
      params.ref.mirostat_tau = context.mirostatTau;
      params.ref.mirostat_eta = context.mirostatEta;

      _nativeLibrary.core_init(params);

      ReceivePort receivePort = ReceivePort();
      _sendPort = receivePort.sendPort;
      _send(input);

      Completer completer = Completer();
      receivePort.listen((data) {
        if (data is String) {
          callback.call(data);
        } else if (data is SendPort) {
          completer.complete();
        } else if (data is int) {
          GenerationManager.busy = false;
          callback.call("");
        }
      });
      await completer.future;
    } catch (e) {
      Logger.log(e.toString());
    }
  }

  void _send(String input) async {
    Logger.log("Input: $input");
    Isolate.spawn(_promptIsolate, {'input': input, 'port': _sendPort});
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
