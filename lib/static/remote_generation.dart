import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/static/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:langchain_ollama/langchain_ollama.dart';
import 'package:langchain_mistralai/langchain_mistralai.dart';
import 'package:provider/provider.dart';

class RemoteGeneration {
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

  static void prompt(
    String input, 
    BuildContext context,
    void Function(String?) callback
  ) async {
    _requestPermission().then((value) {
      if (!value) {
        return;
      }
    });

    final ai = context.read<AiPlatform>();
    final character = context.read<Character>();
    final session = context.read<Session>();

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

  static Future<List<String>> getOptions(AiPlatform ai) async {
    switch (ai.apiType) {
      case AiPlatformType.ollama:
        bool permissionGranted = await _requestPermission();
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

  static Future<bool> _requestPermission() async {
    if ((Platform.isAndroid || Platform.isIOS)) {
      // If nearby devices is granted or android version is below 12.0
      if (await Permission.nearbyWifiDevices.request().isGranted) {
        Logger.log("Nearby Devices - Permission granted");
        return true;
      } else if (Platform.isAndroid &&
          await DeviceInfoPlugin()
                  .androidInfo
                  .then((value) => value.version.sdkInt) <
              31) {
        Logger.log("Nearby Devices - Android version is below 12.0");
        return true;
      } else {
        Logger.log("Nearby Devices - Permission denied");
        return false;
      }
    }
    return true;
  }
}
