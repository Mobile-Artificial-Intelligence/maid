import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:maid/providers/model.dart';
import 'package:maid/static/generation_manager.dart';
import 'package:maid/static/logger.dart';
import 'package:maid/models/generation_options.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:langchain_ollama/langchain_ollama.dart';
import 'package:langchain_mistralai/langchain_mistralai.dart';

class RemoteGeneration {
  static void ollamaRequest(List<ChatMessage> chatMessages,
      GenerationOptions options, StreamController<String> stream) async {
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

      final response = await chat(chatMessages);

      stream.add(response.content);
    } catch (e) {
      Logger.log('Error: $e');
    }

    GenerationManager.busy = false;
  }

  static void openAiRequest(List<ChatMessage> chatMessages,
      GenerationOptions options, StreamController<String> stream) async {
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

      final response = await chat(chatMessages);

      stream.add(response.content);
    } catch (e) {
      Logger.log('Error: $e');
    }

    GenerationManager.busy = false;
  }

  static void mistralRequest(List<ChatMessage> chatMessages,
      GenerationOptions options, StreamController<String> stream) async {
    try {
      final chat = ChatMistralAI(
        baseUrl: '${options.remoteUrl}/v1',
        defaultOptions: ChatMistralAIOptions(
          model: options.remoteModel ?? 'mistral-small',
          topP: options.topP,
          temperature: options.temperature,
        ),
      );

      final response = await chat(chatMessages);

      stream.add(response.content);
    } catch (e) {
      Logger.log('Error: $e');
    }

    GenerationManager.busy = false;
  }

  static void prompt(String input, GenerationOptions options,
      StreamController<String> stream) async {
    _requestPermission().then((value) {
      if (!value) {
        return;
      }
    });

    List<ChatMessage> chatMessages = [];

    chatMessages.add(ChatMessage.system(options.prePrompt));

    for (var message in options.messages) {
      switch (message['role']) {
        case "user":
          chatMessages.add(ChatMessage.humanText(message['content']));
          break;
        case "assistant":
          chatMessages.add(ChatMessage.ai(message['content']));
          break;
        case "system":
          chatMessages.add(ChatMessage.system(message['content']));
          break;
        default:
          break;
      }
    }

    chatMessages.add(ChatMessage.humanText(input));

    switch (options.apiType) {
      case ApiType.ollama:
        ollamaRequest(chatMessages, options, stream);
        break;
      case ApiType.openAI:
        openAiRequest(chatMessages, options, stream);
        break;
      default:
        break;
    }
  }

  static Future<List<String>> getOptions(Model model) async {
    if (model.apiType == ApiType.openAI) {
      return ["gpt-3.5-turbo", "gpt-4-32k"];
    }

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
  }

  static Future<bool> _requestPermission() async {
    if ((Platform.isAndroid || Platform.isIOS)) {
      if (await Permission.nearbyWifiDevices.request().isGranted) {
        Logger.log("Nearby Devices - Permission granted");
        return true;
      } else {
        Logger.log("Nearby Devices - Permission denied");
        return false;
      }
    }
    return true;
  }
}
