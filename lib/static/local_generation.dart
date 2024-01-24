import 'dart:async';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'package:maid/classes/generation_options.dart';
import 'package:maid/static/logger.dart';

class LocalGeneration {
  static LlamaProcessor? llamaProcessor;
  static Completer completer = Completer();
  static Timer? _timer;
  static DateTime? _startTime;

  static void prompt(
    String input,
    GenerationOptions options,
    void Function(String?) callback
  ) async {
    if (llamaProcessor == null) {
      ModelParams modelParams = ModelParams();
      modelParams.format = options.promptFormat;
      ContextParams contextParams = ContextParams();
      contextParams.batch = 512;
      contextParams.context = 512;

      llamaProcessor = LlamaProcessor(
        options.path!, 
        modelParams, 
        contextParams
      );
    }

    llamaProcessor!.stream.listen((data) {
      _resetTimer();
      callback.call(data);
    });

    llamaProcessor?.prompt(input);
    await completer.future;
    callback.call(null);
    Logger.log('Local generation completed');
  }

  static void _resetTimer() {
    _timer?.cancel();
    if (_startTime != null) {
      final elapsed = DateTime.now().difference(_startTime!);
      _startTime = DateTime.now();
      _timer = Timer(elapsed * 3, stop);
    } else {
      _startTime = DateTime.now();
      _timer = Timer(const Duration(seconds: 5), stop);
    }
  }

  static void stop() {
    _timer?.cancel();
    llamaProcessor?.stop();
    completer.complete();
    Logger.log('Local generation stopped');
  }

  static void dispose() {
    _timer?.cancel();
    llamaProcessor?.unloadModel();
    llamaProcessor = null;
    Logger.log('Local generation disposed');
  }
}
