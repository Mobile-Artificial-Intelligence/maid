import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:maid/providers/model.dart';
import 'package:maid/static/generation_manager.dart';
import 'package:maid/static/logger.dart';
import 'package:maid/types/generation_options.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';

class RemoteGeneration {
  static void ollamaRequest(String input, GenerationOptions options,
      void Function(String) callback) async {
    var messages = options.messages;
    messages.insert(0, {"role": "system", "content": options.prePrompt});
    messages.add({"role": "user", "content": input});

    final url = Uri.parse("${options.remoteUrl}/api/chat");
    final headers = {"Content-Type": "application/json", "User-Agent": "MAID"};
    final body = json.encode({
      "model": options.remoteModel ?? "llama2:7b-chat",
      "messages": messages,
      "options": {
        "num_keep": options.nKeep,
        "seed": options.seed,
        "num_predict": options.nPredict,
        "top_k": options.topK,
        "top_p": options.topP,
        "tfs_z": options.tfsZ,
        "typical_p": options.typicalP,
        "repeat_last_n": options.penaltyLastN,
        "temperature": options.temperature,
        "repeat_penalty": options.penaltyRepeat,
        "presence_penalty": options.penaltyPresent,
        "frequency_penalty": options.penaltyFreq,
        "mirostat": options.mirostat,
        "mirostat_tau": options.mirostatTau,
        "mirostat_eta": options.mirostatEta,
        "penalize_newline": options.penalizeNewline != 0 ? true : false,
        "num_ctx": options.nCtx,
        "num_batch": options.nBatch,
        "num_thread": options.nThread,
      },
      "stream": true
    });

    try {
      var request = Request("POST", url)
        ..headers.addAll(headers)
        ..body = body;

      final streamedResponse = await request.send();

      await for (var value in streamedResponse.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        final data = json.decode(value);
        final responseText = data['message']['content'] as String?;
        final done = data['done'] as bool?;

        if (responseText != null && responseText.isNotEmpty) {
          callback.call(responseText);
        }

        if (done ?? false) {
          break;
        }
      }
    } catch (e) {
      Logger.log('Error: $e');
    }

    GenerationManager.busy = false;
    callback.call("");
  }

  static void openAiRequest(String input, GenerationOptions options,
      void Function(String) callback) async {
    var messages = options.messages;
    messages.insert(0, {"role": "system", "content": options.prePrompt});
    messages.add({"role": "user", "content": input});

    List<ChatMessage> chatMessages = [];

    for (var message in messages) {
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

    try {
      final chat = ChatOpenAI(
        apiKey: options.apiKey,
        defaultOptions: ChatOpenAIOptions(
          temperature: options.temperature,
          frequencyPenalty: options.penaltyFreq,
          presencePenalty: options.penaltyPresent,
          maxTokens: options.nPredict,
          topP: options.topP,
        ),
      );

      final response = await chat(chatMessages);

      callback.call(response.content);
    } catch (e) {
      Logger.log('Error: $e');
    }

    GenerationManager.busy = false;
    callback.call("");
  }

  static void prompt(String input, GenerationOptions options,
      void Function(String) callback) async {
    _requestPermission().then((value) {
      if (!value) {
        return;
      }
    });

    switch (options.apiType) {
      case ApiType.ollama:
        ollamaRequest(input, options, callback);
        break;
      case ApiType.openAI:
        openAiRequest(input, options, callback);
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
