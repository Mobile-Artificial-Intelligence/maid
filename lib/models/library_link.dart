import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:maid/bindings.dart';
import 'package:maid/models/generation_options.dart';
import 'package:maid/models/isolate_message.dart';
import 'package:maid/providers/model.dart';
import 'package:maid/static/logger.dart';

class LibraryLink {
  static SendPort? _sendPort;
  static NativeLibrary? _nativeLibrary;

  static void _maidLoggerBridge(Pointer<Char> buffer) {
    try {
      Logger.log(buffer.cast<Utf8>().toDartString());
    } catch (e) {
      Logger.log(e.toString());
    }
  }

  static void _maidOutputBridge(int code, Pointer<Char> buffer) {
    try {
      if (code == return_code.CONTINUE) {
        _sendPort?.send(buffer.cast<Utf8>().toDartString());
      } else if (code == return_code.STOP) {
        _sendPort?.send(IsolateCode.stop);
      }
    } catch (e) {
      Logger.log(e.toString());
    }
  }

  static NativeLibrary loadNativeLibrary() {
    DynamicLibrary coreDynamic = DynamicLibrary.process();

    if (Platform.isWindows) coreDynamic = DynamicLibrary.open('core.dll');
    if (Platform.isLinux || Platform.isAndroid) {
      coreDynamic = DynamicLibrary.open('libcore.so');
    }

    return NativeLibrary(coreDynamic);
  }

  LibraryLink(GenerationOptions options) {
    _nativeLibrary = loadNativeLibrary();

    String prePrompt = options.prePrompt;

    for (var message in options.messages) {
      prePrompt += "\n${message['role']} ${message['content']}";
    }

    final params = calloc<maid_params>();
    
    String systemMessage = options.systemPrompt;

    switch (options.promptFormat) {
      case PromptFormat.raw:
        break;
      case PromptFormat.chatml:
        params.ref.input_prefix = "\n<|im_start|>user\n".toNativeUtf8().cast<Char>();
        params.ref.input_suffix = "<|im_end|>\n<|im_start|>assistant\n".toNativeUtf8().cast<Char>();
        params.ref.prompt = "\n<|im_start|>system\n$systemMessage\n<|im_end|>".toNativeUtf8().cast<Char>();
        break;
      case PromptFormat.alpaca:
        params.ref.input_prefix = "\n\n### Instruction:\n\n".toNativeUtf8().cast<Char>();
        params.ref.input_suffix = "\n\n### Response:\n\n".toNativeUtf8().cast<Char>();
        params.ref.prompt = "\n\n### System:\n\n$systemMessage".toNativeUtf8().cast<Char>();
        break;
    }

    params.ref.path = options.path!.toNativeUtf8().cast<Char>();
    params.ref.preprompt = prePrompt.toNativeUtf8().cast<Char>();
    params.ref.format = options.promptFormat.index;
    params.ref.seed = options.seed;
    params.ref.n_ctx = options.nCtx;
    params.ref.n_threads = options.nThread;
    params.ref.n_batch = options.nBatch;
    params.ref.n_predict = options.nPredict;
    params.ref.n_keep = options.nKeep;
    params.ref.penalize_nl = options.penalizeNewline;
    params.ref.top_k = options.topK;
    params.ref.top_p = options.topP;
    params.ref.min_p = options.minP;
    params.ref.tfs_z = options.tfsZ;
    params.ref.typical_p = options.typicalP;
    params.ref.temp = options.temperature;
    params.ref.penalty_last_n = options.penaltyLastN;
    params.ref.penalty_repeat = options.penaltyRepeat;
    params.ref.penalty_freq = options.penaltyFreq;
    params.ref.penalty_present = options.penaltyPresent;
    params.ref.mirostat = options.mirostat;
    params.ref.mirostat_tau = options.mirostatTau;
    params.ref.mirostat_eta = options.mirostatEta;

    _nativeLibrary!.core_init(params, Pointer.fromFunction(_maidLoggerBridge));
  }

  static _promptIsolate(Map<String, dynamic> args) async {
    _sendPort = args['port'] as SendPort?;
    String input = args['input'];
    Pointer<Char> text = input.trim().toNativeUtf8().cast<Char>();

    _nativeLibrary = loadNativeLibrary();

    _nativeLibrary!.core_prompt(text, Pointer.fromFunction(_maidOutputBridge));
  }

  void prompt(SendPort sendPort, String input) async {
    _sendPort = sendPort;
    Isolate.spawn(_promptIsolate, {'input': input, 'port': sendPort});
  }

  void stop() {
    _nativeLibrary!.core_stop();
    _sendPort!.send(IsolateCode.stop);
  }

  void dispose() {
    _nativeLibrary!.core_cleanup();
    _sendPort!.send(IsolateCode.dispose);
  }
}
