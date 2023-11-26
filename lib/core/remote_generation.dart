import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:maid/static/memory_manager.dart';
import 'package:maid/types/character.dart';
import 'package:maid/static/host.dart';
import 'package:maid/static/logger.dart';
import 'package:maid/static/message_manager.dart';
import 'package:maid/types/model.dart';
import 'package:permission_handler/permission_handler.dart';

class RemoteGeneration {
  static List<int> _context = [];
  static List<Map<String, dynamic>> _messages = [];
  
  static void prompt(String input, Model model) async {   
    _requestPermission().then((value) {
      if (!value) {
        return;
      }
    });
    
    _messages = character.examples;
    _messages.addAll(MessageManager.getMessages());
    
    final url = Uri.parse("${Host.url}/api/generate");
    final headers = {"Content-Type": "application/json"};
    final body = json.encode({
      "model": model.parameters["remote_model"] ?? "llama2:7b-chat",
      "prompt": input,
      "context": _context, // TODO: DEPRECATED SOON
      "system": character.prePrompt,
      "messages": _messages,
      "options": {
        "num_keep": model.parameters["n_keep"],
        "seed": model.parameters["random_seed"] ? -1 : model.parameters["seed"],
        "num_predict": model.parameters["n_predict"],
        "top_k": model.parameters["top_k"],
        "top_p": model.parameters["top_p"],
        "tfs_z": model.parameters["tfs_z"],
        "typical_p": model.parameters["typical_p"],
        "repeat_last_n": model.parameters["penalty_last_n"],
        "temperature": model.parameters["temperature"],
        "repeat_penalty": model.parameters["penalty_repeat"],
        "presence_penalty": model.parameters["penalty_present"],
        "frequency_penalty": model.parameters["penalty_freq"],
        "mirostat": model.parameters["mirostat"],
        "mirostat_tau": model.parameters["mirostat_tau"],
        "mirostat_eta": model.parameters["mirostat_eta"],
        "penalize_newline": model.parameters["penalize_nl"],
        "num_ctx": model.parameters["n_ctx"],
        "num_batch": model.parameters["n_batch"],
        "num_thread": model.parameters["n_threads"],
      }
    });

    try {
      var request = http.Request("POST", url)
        ..headers.addAll(headers)
        ..body = body;

      final streamedResponse = await request.send();

      await for (var value in streamedResponse.stream.transform(utf8.decoder).transform(const LineSplitter())) {
        final data = json.decode(value);
        final responseText = data['response'] as String?;
        final newContext = data['context'] as List<dynamic>?; 
        final done = data['done'] as bool?;

        if (newContext != null) {
          _context = newContext.cast<int>();
        }

        if (responseText != null && responseText.isNotEmpty) {
          MessageManager.stream(responseText);
        }

        if (done ?? false) {
          break;
        }
      }
    } catch (e) {
      Logger.log('Error: $e');
    }

    MessageManager.busy = false;
    MessageManager.stream("");
    MemoryManager.saveMisc();
  }

  static Future<List<String>> getModels() async {
    bool permissionGranted = await _requestPermission();
    if (!permissionGranted) {
      return [];
    }

    final url = Uri.parse("${Host.url}/api/tags");
    final headers = {"Accept": "application/json"};

    try {
      var request = http.Request("GET", url)
        ..headers.addAll(headers);

      var response = await request.send();
      var responseString = await response.stream.bytesToString();
      var data = json.decode(responseString);

      List<String> models = [];
      if (data['models'] != null) {
        for (var model in data['models']) {
          models.add(model['name']);
        }
      }

      return models;
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