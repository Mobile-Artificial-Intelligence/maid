import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:maid/core/bindings.dart';
import 'package:maid/models/generation_options.dart';
import 'package:maid/static/logger.dart';

class LibraryLink {
  late NativeLibrary _nativeLibrary;

  static void _maidLoggerBridge(Pointer<Char> buffer) {
    try {
      Logger.log(buffer.cast<Utf8>().toDartString());
    } catch (e) {
      Logger.log(e.toString());
    }
  }

  LibraryLink(GenerationOptions options) {
    DynamicLibrary coreDynamic = DynamicLibrary.process();

    if (Platform.isWindows) coreDynamic = DynamicLibrary.open('core.dll');
    if (Platform.isLinux || Platform.isAndroid) {
      coreDynamic = DynamicLibrary.open('libcore.so');
    }
    _nativeLibrary = NativeLibrary(coreDynamic);

    final params = calloc<maid_params>();
    params.ref.path = options.path.toString().toNativeUtf8().cast<Char>();
    params.ref.preprompt = options.prePrompt.toNativeUtf8().cast<Char>();
    params.ref.input_prefix =
        options.userAlias.trim().toNativeUtf8().cast<Char>();
    params.ref.input_suffix =
        options.responseAlias.trim().toNativeUtf8().cast<Char>();
    params.ref.seed = options.seed;
    params.ref.n_ctx = options.nCtx;
    params.ref.n_threads = options.nThread;
    params.ref.n_batch = options.nBatch;
    params.ref.n_predict = options.nPredict;
    params.ref.n_keep = options.nKeep;
    params.ref.instruct = options.instruct;
    params.ref.interactive = options.interactive;
    params.ref.chatml = options.chatml;
    params.ref.penalize_nl = options.penalizeNewline;
    params.ref.top_k = options.topK;
    params.ref.top_p = options.topP;
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

    _nativeLibrary.core_init(params, Pointer.fromFunction(_maidLoggerBridge));
  }

  void prompt(Pointer<Char> input, Pointer<maid_output_stream> maidOutput) {
    _nativeLibrary.core_prompt(input, maidOutput);
  }

  void stop() {
    _nativeLibrary.core_stop();
  }

  void dispose() {
    _nativeLibrary.core_cleanup();
  }
}
