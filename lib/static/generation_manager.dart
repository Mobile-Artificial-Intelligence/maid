import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:langchain_mistralai/langchain_mistralai.dart';
import 'package:langchain_ollama/langchain_ollama.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/providers/user.dart';
import 'package:maid/static/logger.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:maid/static/utilities.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:maid_llm/maid_llm.dart';

class GenerationManager {
  static MaidLLM? maidllm;
  static Completer? _completer;

  static void prompt(String input, BuildContext context) async {
    context.read<Session>().busy = true;

    final ai = context.read<AiPlatform>();
    final user = context.read<User>();
    final character = context.read<Character>();
    final session = context.read<Session>();

    bool permissionGranted = await getNearbyDevicesPermission();
    if (!permissionGranted) {
      return;
    }

    List<ChatMessage> chatMessages = [];

    final prePrompt = '''
      ${Utilities.formatPlaceholders(character.description, user.name, character.name)}\n\n
      ${Utilities.formatPlaceholders(character.personality, user.name, character.name)}\n\n
      ${Utilities.formatPlaceholders(character.scenario, user.name, character.name)}\n\n
      ${Utilities.formatPlaceholders(character.system, user.name, character.name)}\n\n
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

      chatMessages.add(ChatMessage.system(Utilities.formatPlaceholders(
          character.system, user.name, character.name)));
    }

    chatMessages.add(ChatMessage.humanText(input));

    switch (ai.apiType) {
      case AiPlatformType.local:
        localRequest(chatMessages, ai, session.stream);
        break;
      case AiPlatformType.ollama:
        ollamaRequest(chatMessages, ai, session.stream);
        break;
      case AiPlatformType.openAI:
        openAiRequest(chatMessages, ai, session.stream);
        break;
      case AiPlatformType.mistralAI:
        mistralRequest(chatMessages, ai, session.stream);
        break;
      default:
        break;
    }
  }

  static void localRequest(List<ChatMessage> chatMessages, AiPlatform ai,
      void Function(String?) callback) async {
    _completer = Completer();

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

    GptParams gptParams = GptParams();
    gptParams.seed = ai.randomSeed ? Random().nextInt(1000000) : ai.seed;
    gptParams.nThreads = ai.nThread;
    gptParams.nThreadsBatch = ai.nThread;
    gptParams.nPredict = ai.nPredict;
    gptParams.nCtx = ai.nCtx;
    gptParams.nBatch = ai.nBatch;
    gptParams.nKeep = ai.nKeep;
    gptParams.sparams = samplingParams;
    gptParams.model = ai.model;
    gptParams.instruct = ai.promptFormat == PromptFormat.alpaca;
    gptParams.chatml = ai.promptFormat == PromptFormat.chatml;

    maidllm = MaidLLM(gptParams);

    maidllm?.prompt(chatMessages, log: Logger.log).listen((message) {
      callback.call(message);
    }).onDone(() {
      _completer?.complete();
    });
    await _completer?.future;
    callback.call(null);
    maidllm?.clear();
    maidllm = null;
    Logger.log('Local generation completed');
  }

  static void ollamaRequest(List<ChatMessage> chatMessages, AiPlatform ai,
      void Function(String?) callback) async {
    try {
      ChatOllama chat;
      if (ai.useDefault) {
        chat = ChatOllama(
          baseUrl: '${ai.url}/api',
          defaultOptions: ChatOllamaOptions(
            model: ai.model,
          ),
        );
      } else {
        chat = ChatOllama(
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
      }

      final stream = chat.stream(PromptValue.chat(chatMessages));

      await for (final ChatResult response in stream) {
        callback.call(response.firstOutputAsString);
      }
    } catch (e) {
      Logger.log('Error: $e');
    }

    callback.call(null);
  }

  static void openAiRequest(List<ChatMessage> chatMessages, AiPlatform ai,
      void Function(String?) callback) async {
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

  static void mistralRequest(List<ChatMessage> chatMessages, AiPlatform ai,
      void Function(String?) callback) async {
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

  static void stop() {
    maidllm?.stop();
    _completer?.complete();
    Logger.log('Local generation stopped');
  }

  static Future<List<String>> getOptions(AiPlatform ai) async {
    switch (ai.apiType) {
      case AiPlatformType.ollama:
        bool permissionGranted = await getNearbyDevicesPermission();
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
    bool permissionGranted = await getNearbyDevicesPermission();
    if (!permissionGranted) {
      return '';
    }

    final localIP = await NetworkInfo().getWifiIP();

    // Get the first 3 octets of the local IP
    final baseIP = ipToCSubnet(localIP ?? '');

    // Scan the local network for hosts
    final hosts =
        await LanScanner(debugLogging: true).quickIcmpScanAsync(baseIP);

    // Create a list to hold all the futures
    var futures = <Future<String>>[];

    for (var host in hosts) {
      futures.add(checkIp(host.internetAddress.address));
    }

    // Wait for all futures to complete
    final results = await Future.wait(futures);

    // Filter out all empty results and return the first valid URL, if any
    final validUrls = results.where((result) => result.isNotEmpty);
    return validUrls.isNotEmpty ? validUrls.first : '';
  }

  static Future<String> checkIp(String ip) async {
    final url = Uri.parse('http://$ip:11434/api/tags');
    final headers = {"Accept": "application/json"};

    try {
      var request = Request("GET", url)..headers.addAll(headers);
      var response = await request.send();
      if (response.statusCode == 200) {
        Logger.log('Found Ollama at $ip');
        return 'http://$ip:11434';
      }
    } catch (e) {
      // Ignore
    }

    return '';
  }

  static Future<bool> getNearbyDevicesPermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return true;
    }

    // Get sdk version
    final sdk = await DeviceInfoPlugin()
        .androidInfo
        .then((value) => value.version.sdkInt);
    var permissions = <Permission>[]; // List of permissions to request

    if (sdk <= 32) {
      // ACCESS_FINE_LOCATION is required
      permissions.add(Permission.location);
    } else {
      // NEARBY_WIFI_DEVICES is required
      permissions.add(Permission.nearbyWifiDevices);
    }

    // Request permissions and check if all are granted
    Map<Permission, PermissionStatus> statuses = await permissions.request();
    bool allPermissionsGranted =
        statuses.values.every((status) => status.isGranted);

    if (allPermissionsGranted) {
      Logger.log("Nearby Devices - permission granted");
      return true;
    } else {
      Logger.log("Nearby Devices - permission denied");
      return false;
    }
  }
}
