import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:maid/classes/generation_options.dart';
import 'package:maid/providers/model.dart';
import 'package:maid/static/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:langchain_ollama/langchain_ollama.dart';
import 'package:langchain_mistralai/langchain_mistralai.dart';

class RemoteGeneration {
  static void ollamaRequest(List<ChatMessage> chatMessages,
      GenerationOptions options, void Function(String?) callback) async {
    try {
      final chat = ChatOllama(
        baseUrl: '${options.remoteUrl}/api',
        defaultOptions: ChatOllamaOptions(
          model: options.remoteModel ?? 'llama2',
          numKeep: options.nKeep,
          seed: options.seed,
          numPredict: options.nPredict,
          topK: options.topK,
          topP: options.topP,
          typicalP: options.typicalP,
          temperature: options.temperature,
          repeatPenalty: options.penaltyRepeat,
          frequencyPenalty: options.penaltyFreq,
          presencePenalty: options.penaltyPresent,
          mirostat: options.mirostat,
          mirostatTau: options.mirostatTau,
          mirostatEta: options.mirostatEta,
          numCtx: options.nCtx,
          numBatch: options.nBatch,
          numThread: options.nThread,
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

  static void openAiRequest(List<ChatMessage> chatMessages,
      GenerationOptions options, void Function(String?) callback) async {
    try {
      final chat = ChatOpenAI(
        baseUrl: options.remoteUrl,
        apiKey: options.apiKey,
        defaultOptions: ChatOpenAIOptions(
          model: options.remoteModel ?? 'gpt-3.5-turbo',
          temperature: options.temperature,
          frequencyPenalty: options.penaltyFreq,
          presencePenalty: options.penaltyPresent,
          maxTokens: options.nPredict,
          topP: options.topP,
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

  static void mistralRequest(List<ChatMessage> chatMessages,
      GenerationOptions options, void Function(String?) callback) async {
    try {
      final chat = ChatMistralAI(
        baseUrl: '${options.remoteUrl}/v1',
        apiKey: options.apiKey,
        defaultOptions: ChatMistralAIOptions(
          model: options.remoteModel ?? 'mistral-small',
          topP: options.topP,
          temperature: options.temperature,
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

  static void prompt(String input, GenerationOptions options,
      void Function(String?) callback) async {
    _requestPermission().then((value) {
      if (!value) {
        return;
      }
    });

    List<ChatMessage> chatMessages = [];

    final prePrompt = '''
      ${options.description}\n\n
      ${options.personality}\n\n
      ${options.scenario}\n\n
      ${options.system}\n\n
    ''';

    chatMessages.add(ChatMessage.system(prePrompt));

    for (var message in options.messages) {
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

      chatMessages.add(ChatMessage.system(options.system));
    }

    chatMessages.add(ChatMessage.humanText(input));

    switch (options.apiType) {
      case ApiType.ollama:
        ollamaRequest(chatMessages, options, callback);
        break;
      case ApiType.openAI:
        openAiRequest(chatMessages, options, callback);
        break;
      case ApiType.mistralAI:
        mistralRequest(chatMessages, options, callback);
        break;
      default:
        break;
    }
  }

  static Future<List<String>> getOptions(Model model) async {
    switch (model.apiType) {
      case ApiType.ollama:
        bool permissionGranted = await _requestPermission();
        if (!permissionGranted) {
          return [];
        }

        final url = Uri.parse("${model.parameters["remote_url"]}/api/tags");
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
      case ApiType.openAI:
        return ["gpt-3.5-turbo", "gpt-4-32k"];
      case ApiType.mistralAI:
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
