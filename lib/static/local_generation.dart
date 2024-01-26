import 'dart:async';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'package:maid/classes/generation_options.dart';
import 'package:maid/static/logger.dart';

class LocalGeneration {
  static LlamaProcessor? llamaProcessor;
  static Completer? _completer;
  static Timer? _timer;
  static DateTime? _startTime;

  static void prompt(
    String input,
    GenerationOptions options,
    void Function(String?) callback
  ) async {
    _timer = null;
    _startTime = null;
    _completer = Completer();

    ModelParams modelParams = ModelParams();
    modelParams.format = options.promptFormat;
    ContextParams contextParams = ContextParams();
    contextParams.batch = options.nBatch;
    contextParams.context = options.nCtx;
    contextParams.seed = options.seed;
    contextParams.threads = options.nThread;
    contextParams.threadsBatch = options.nThread;
    
    llamaProcessor = LlamaProcessor(
      options.path!, 
      modelParams, 
      contextParams
    );

    List<Map<String, dynamic>> messages = [
      {
        'role': 'system',
        'content': '''
          ${options.description}\n\n
          ${options.personality}\n\n
          ${options.scenario}\n\n
          ${options.system}\n\n
        '''
      }
    ];

    for (var message in options.messages) {
      switch (message['role']) {
        case "user":
          messages.add(message);
          break;
        case "assistant":
          messages.add(message);
          break;
        case "system": // Under normal circumstances, this should never be called
          messages.add(message);
          break;
        default:
          break;
      }

      messages.add({
        'role': 'system',
        'content': options.system
      });
    }

    llamaProcessor!.messages = options.messages;

    llamaProcessor!.stream.listen((data) {
      _resetTimer();
      callback.call(data);
    });

    llamaProcessor?.prompt(input);
    await _completer?.future;
    callback.call(null);
    llamaProcessor?.unloadModel();
    llamaProcessor = null;
    Logger.log('Local generation completed');
  }

  static void _resetTimer() {
    _timer?.cancel();
    if (_startTime != null) {
      final elapsed = DateTime.now().difference(_startTime!);
      _startTime = DateTime.now();
      _timer = Timer(elapsed * 10, stop);
    } else {
      _startTime = DateTime.now();
      _timer = Timer(const Duration(seconds: 5), stop);
    }
  }

  static void stop() {
    _timer?.cancel();
    llamaProcessor?.stop();
    _completer?.complete();
    Logger.log('Local generation stopped');
  }
}
