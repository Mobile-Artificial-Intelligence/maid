import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_mistralai/langchain_mistralai.dart';
import 'package:langchain_ollama/langchain_ollama.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/static/logger.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:maid/static/networking.dart';
import 'package:provider/provider.dart';

class GenerationManager {
  static LlamaProcessor? _llamaProcessor;
  static Completer? _completer;
  static Timer? _timer;
  static DateTime? _startTime;

  static void prompt(String input, BuildContext context) {
    context.read<Session>().busy = true;

    if (context.read<AiPlatform>().apiType == AiPlatformType.local) {
      localPrompt(input, context, context.read<Session>().stream);
    } else {
      remotePrompt(input, context, context.read<Session>().stream);
    }
  }

  static void localPrompt(String input, BuildContext context,
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
        path: ai.model,
        modelParams: modelParams,
        contextParams: contextParams,
        samplingParams: samplingParams,
        onDone: stop
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

  static void remotePrompt(
    String input, 
    BuildContext context,
    void Function(String?) callback
  ) async {
    final ai = context.read<AiPlatform>();
    final character = context.read<Character>();
    final session = context.read<Session>();

    bool permissionGranted = await Networking.getNearbyDevicesPermission();
    if (!permissionGranted) {
      return;
    }

    List<ChatMessage> chatMessages = [];

    final prePrompt = '''
      ${character.formatPlaceholders(character.description)}\n\n
      ${character.formatPlaceholders(character.personality)}\n\n
      ${character.formatPlaceholders(character.scenario)}\n\n
      ${character.formatPlaceholders(character.system)}\n\n
    ''';

    List<Map<String, dynamic>> messages = [
      {
        'role': 'system',
        'content': prePrompt,
      }
    ];

    if (character.useExamples) {
      messages.addAll(character.examples);
    }

    messages.addAll(session.getMessages());

    for (var message in messages) {
      switch (message['role']) {
        case "user":
          chatMessages.add(ChatMessage.humanText(message['content']));
          break;
        case "assistant":
          chatMessages.add(ChatMessage.ai(message['content']));
          break;
        case "system": // Under normal circumstances, this should never be called
          chatMessages.add(ChatMessage.system(message['content']));
          break;
        default:
          break;
      }

      chatMessages.add(ChatMessage.system(character.formatPlaceholders(character.system)));
    }

    chatMessages.add(ChatMessage.humanText(input));

    switch (ai.apiType) {
      case AiPlatformType.ollama:
        ollamaRequest(chatMessages, ai, callback);
        break;
      case AiPlatformType.openAI:
        openAiRequest(chatMessages, ai, callback);
        break;
      case AiPlatformType.mistralAI:
        mistralRequest(chatMessages, ai, callback);
        break;
      default:
        break;
    }
  }

  static void ollamaRequest(
    List<ChatMessage> chatMessages,
    AiPlatform ai, 
    void Function(String?) callback
  ) async {
    try {
      final chat = ChatOllama(
        baseUrl: '${ai.url}/api',
        defaultOptions: ChatOllamaOptions(
          model: ai.model,
          numKeep: ai.nKeep,
          seed: ai.seed,
          numPredict: ai.nPredict,
          topK: ai.topK,
          topP: ai.topP,
          typicalP: ai.typicalP,
          temperature: ai.temperature,
          repeatPenalty: ai.penaltyRepeat,
          frequencyPenalty: ai.penaltyFreq,
          presencePenalty: ai.penaltyPresent,
          mirostat: ai.mirostat,
          mirostatTau: ai.mirostatTau,
          mirostatEta: ai.mirostatEta,
          numCtx: ai.nCtx,
          numBatch: ai.nBatch,
          numThread: ai.nThread,
        ),
      );

      final stream = chat.stream(PromptValue.chat(chatMessages));

      await for (final ChatResult response in stream) {
        callback.call(response.firstOutputAsString);
      }
    } catch (e) {
      Logger.log('Error: $e');
    }

    callback.call(null);
  }

  static void openAiRequest(
    List<ChatMessage> chatMessages,
    AiPlatform ai, 
    void Function(String?) callback
  ) async {
    try {
      final chat = ChatOpenAI(
        baseUrl: ai.url,
        apiKey: ai.apiKey,
        defaultOptions: ChatOpenAIOptions(
          model: ai.model,
          temperature: ai.temperature,
          frequencyPenalty: ai.penaltyFreq,
          presencePenalty: ai.penaltyPresent,
          maxTokens: ai.nPredict,
          topP: ai.topP,
        ),
      );

      final stream = chat.stream(PromptValue.chat(chatMessages));

      await for (final ChatResult response in stream) {
        callback.call(response.firstOutputAsString);
      }
    } catch (e) {
      Logger.log('Error: $e');
    }

    callback.call(null);
  }

  static void mistralRequest(
    List<ChatMessage> chatMessages,
    AiPlatform ai, 
    void Function(String?) callback
  ) async {
    try {
      final chat = ChatMistralAI(
        baseUrl: '${ai.url}/v1',
        apiKey: ai.apiKey,
        defaultOptions: ChatMistralAIOptions(
          model: ai.model,
          topP: ai.topP,
          temperature: ai.temperature,
        ),
      );

      final stream = chat.stream(PromptValue.chat(chatMessages));

      await for (final ChatResult response in stream) {
        callback.call(response.firstOutputAsString);
      }
    } catch (e) {
      Logger.log('Error: $e');
    }

    callback.call(null);
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

  static Future<List<String>> getOptions(AiPlatform ai) async {
    switch (ai.apiType) {
      case AiPlatformType.ollama:
        bool permissionGranted = await Networking.getNearbyDevicesPermission();
        if (!permissionGranted) {
          return [];
        }

        final url = Uri.parse("${ai.url}/api/tags");
        final headers = {"Accept": "application/json"};

        try {
          var request = Request("GET", url)..headers.addAll(headers);

          var response = await request.send();
          var responseString = await response.stream.bytesToString();
          var data = json.decode(responseString);

          List<String> options = [];
          if (data['models'] != null) {
            for (var option in data['models']) {
              options.add(option['name']);
            }
          }

          return options;
        } catch (e) {
          Logger.log('Error: $e');
          return [];
        }
      case AiPlatformType.openAI:
        return ["gpt-3.5-turbo", "gpt-4-32k"];
      case AiPlatformType.mistralAI:
        return ["mistral-small", "mistral-medium", "mistral-large"];
      default:
        return [];
    }
  }

  static Future<String> getOllamaUrl() async {
    final localIP = await Networking.getLocalIP();

    // Get the first 3 octets of the local IP
    final baseIP = localIP.split('.').sublist(0, 3).join('.');
    
    for (int i = 1; i <= 254; i++) {
      final ip = '$baseIP.$i';
      final url = Uri.parse('http://$ip:11434/api/tags');
      final headers = {"Accept": "application/json"};

      try {
        var request = Request("GET", url)..headers.addAll(headers);

        var response = await request.send();
        if (response.statusCode == 200) {
          return 'http://$ip:11434';
        }
      } catch (e) {
        Logger.log('Error: $e');
      }
    }

    return '';
  }
}
