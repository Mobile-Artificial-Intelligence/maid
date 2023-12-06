import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:maid/providers/model.dart';
import 'package:maid/static/generation_manager.dart';
import 'package:maid/static/logger.dart';
import 'package:maid/types/generation_context.dart';
import 'package:permission_handler/permission_handler.dart';

class RemoteGeneration {
  static void ollamaRequest(
    String input, 
    GenerationContext context, 
    void Function(String) callback
  ) async {
    var messages = context.messages;
    messages.insert(0, {"role":"system","text":context.prePrompt});
    messages.add({"role":"user","text":input});
    
    final url = Uri.parse("${context.remoteUrl}/api/chat");
    final headers = {
      "Content-Type": "application/json",
      "User-Agent": "MAID"
    };
    final body = json.encode({
      "model": context.remoteModel ?? "llama2:7b-chat",
      "messages": messages,
      "options": {
        "num_keep": context.nKeep,
        "seed": context.seed,
        "num_predict": context.nPredict,
        "top_k": context.topK,
        "top_p": context.topP,
        "tfs_z": context.tfsZ,
        "typical_p": context.typicalP,
        "repeat_last_n": context.penaltyLastN,
        "temperature": context.temperature,
        "repeat_penalty": context.penaltyRepeat,
        "presence_penalty": context.penaltyPresent,
        "frequency_penalty": context.penaltyFreq,
        "mirostat": context.mirostat,
        "mirostat_tau": context.mirostatTau,
        "mirostat_eta": context.mirostatEta,
        "penalize_newline": context.penalizeNewline,
        "num_ctx": context.nCtx,
        "num_batch": context.nBatch,
        "num_thread": context.nThread,
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

  static void openAiRequest(
    String input, 
    GenerationContext context, 
    void Function(String) callback
  ) async {
    var messages = context.messages;
    messages.insert(0, {"role":"system","text":context.prePrompt});
    messages.add({"role":"user","text":input});

    final url = Uri.parse("${context.remoteUrl}/v1/chat/completions");
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${context.apiKey}",
      "User-Agent": "MAID"
    };
    final body = json.encode({
      "model": context.remoteModel ?? "gpt-3.5-turbo",
      "messages": messages,
      "temperature": context.temperature,
      "stream": true
    });

    try {
      final request = Request("POST", url)
        ..headers.addAll(headers)
        ..body = body;
      
      final streamedResponse = await request.send();

      await for (var value in streamedResponse.stream
          .transform(utf8.decoder)
      ) {
        final data = json.decode(value);

        if (data['error'] != null) {
          throw Exception(data['error']);
        }

        final responseText = data['choices']['delta']['content'] as String?;
        final finishReason = data['finish_reason'] as String?;

        if (responseText != null && responseText.isNotEmpty) {
          callback.call(responseText);
        }

        if (finishReason != null) {
          break;
        }
      }
    } catch (e) {
      Logger.log('Error: $e');
    }

    GenerationManager.busy = false;
    callback.call("");
  }

  static void prompt(String input, 
    GenerationContext context,
    void Function(String) callback
  ) async {
    _requestPermission().then((value) {
      if (!value) {
        return;
      }
    });

    switch (context.apiType) {
      case ApiType.ollama:
        ollamaRequest(input, context, callback);
        break;
      case ApiType.openAI:
        openAiRequest(input, context, callback);
        break;
      default:
        break;
    }
  }

  static Future<List<String>> getOptions(Model model) async {
    if (model.apiType == ApiType.openAI) {
      return [
        "gpt-3.5-turbo",
        "gpt-4-32k"
      ];
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
