import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/static/logger.dart';
import 'package:provider/provider.dart';

class LocalGeneration {
  static LlamaProcessor? _llamaProcessor;
  static Completer? _completer;
  static Timer? _timer;
  static DateTime? _startTime;

  static void prompt(String input, BuildContext context,
      void Function(String?) callback) async {
    _timer = null;
    _startTime = null;
    _completer = Completer();

    final ai = context.read<AiPlatform>();
    final character = context.read<Character>();
    final session = context.read<Session>();

    ModelParams modelParams = ModelParams();
    modelParams.format = ai.promptFormat;
    ContextParams contextParams = ContextParams();
    contextParams.batch = ai.nBatch;
    contextParams.context = ai.nCtx;
    contextParams.seed = ai.randomSeed ? Random().nextInt(1000000) : ai.seed;
    contextParams.threads = ai.nThread;
    contextParams.threadsBatch = ai.nThread;
    SamplingParams samplingParams = SamplingParams();
    samplingParams.temp = ai.temperature;
    samplingParams.topK = ai.topK;
    samplingParams.topP = ai.topP;
    samplingParams.tfsZ = ai.tfsZ;
    samplingParams.typicalP = ai.typicalP;
    samplingParams.penaltyLastN = ai.penaltyLastN;
    samplingParams.penaltyRepeat = ai.penaltyRepeat;
    samplingParams.penaltyFreq = ai.penaltyFreq;
    samplingParams.penaltyPresent = ai.penaltyPresent;
    samplingParams.mirostat = ai.mirostat;
    samplingParams.mirostatTau = ai.mirostatTau;
    samplingParams.mirostatEta = ai.mirostatEta;
    samplingParams.penalizeNl = ai.penalizeNewline;

    _llamaProcessor = LlamaProcessor(
      ai.model, 
      modelParams, 
      contextParams, 
      samplingParams
    );

    List<Map<String, dynamic>> messages = [
      {
        'role': 'system',
        'content': '''
          ${character.formatPlaceholders(character.description)}\n\n
          ${character.formatPlaceholders(character.personality)}\n\n
          ${character.formatPlaceholders(character.scenario)}\n\n
          ${character.formatPlaceholders(character.system)}\n\n
        '''
      }
    ];

    if (character.useExamples) {
      messages.addAll(character.examples);
    }

    messages.addAll(session.getMessages());

    _llamaProcessor!.messages = messages;

    _llamaProcessor!.stream.listen((data) {
      _resetTimer();
      callback.call(data);
    });

    _llamaProcessor?.prompt(input);
    await _completer?.future;
    callback.call(null);
    _llamaProcessor?.unloadModel();
    _llamaProcessor = null;
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
    _llamaProcessor?.stop();
    _completer?.complete();
    Logger.log('Local generation stopped');
  }
}
