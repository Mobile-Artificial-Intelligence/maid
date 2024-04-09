import 'dart:convert';
import 'dart:ui';

import 'package:http/http.dart';
import 'package:maid/classes/large_language_model.dart';
import 'package:maid/static/logger.dart';
import 'package:maid_llm/maid_llm.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OpenAiModel extends LargeLanguageModel {
  @override
  LargeLanguageModelType get type => LargeLanguageModelType.openAI;

  OpenAiModel({
    super.listener, 
    super.name,
    super.uri = 'https://api.openai.com/v1/',
    super.token,
    super.seed,
    super.nPredict,
    super.topP,
    super.penaltyPresent,
    super.penaltyFreq,
  });

  OpenAiModel.fromMap(VoidCallback listener, Map<String, dynamic> json) {
    addListener(listener);
    fromMap(json);
  }

  @override
  void fromMap(Map<String, dynamic> json) {
    super.fromMap(json);
    uri = json['url'] ?? 'https://api.openai.com/v1/';
    token = json['token'] ?? '';
    nPredict = json['nPredict'] ?? 512;
    topP = json['topP'] ?? 0.95;
    penaltyPresent = json['penaltyPresent'] ?? 0.0;
    penaltyFreq = json['penaltyFreq'] ?? 0.0;
    notifyListeners();
  }

  @override
  Stream<String> prompt(List<ChatNode> messages) async* {
    List<Map<String, dynamic>> chat = [];

    for (var message in messages) {
      chat.add({
        'role': message.role.name,
        'content': message.content,
      });
    }
    
    try {
      final url = Uri.parse('$uri/v1/chat/completions');
      
      final headers = {
        "Accept": "application/json",
        'Authorization':'Bearer $token',
      };

      final body = {
        'model': name,
        'messages': chat,
        'temperature': temperature,
        'top_p': topP,
        'max_tokens': nPredict,
        'stream': true,
        'random_seed': seed
      };
      
      final request = Request("POST", url)
        ..headers.addAll(headers)
        ..body = json.encode(body);

      final response = await request.send();

      final stream = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in stream) {
        final data = json.decode(line);
        Logger.log('Data: $data');

        final content = data['choices'][0]['delta']['content'] as String?;

        if (content != null && content.isNotEmpty) {
          yield content;
        }
      }
    } catch (e) {
      Logger.log('Error: $e');
    }
  }
  
  @override
  Future<void> updateOptions() async {
    try {
      final url = Uri.parse('$uri/v1/models');

      final headers = {
        "Accept": "application/json",
        'Authorization':'Bearer $token',
      };

      final request = Request("GET", url)
        ..headers.addAll(headers);
      
      final response = await request.send();

      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        final data = json.decode(body);
        Logger.log('Data: $data');

        final models = data['data'] as List<dynamic>?;

        if (models != null) {
          options = models
            .where((model) => model['id'].contains('gpt-3.5') || model['id'].contains('gpt-4'))
            .map((model) => model['id'] as String)
            .toList();
        } else {
          options = [];
        }
      } else {
        throw Exception('Failed to update options: ${response.statusCode}');
      }
    } catch (e) {
      Logger.log('Error: $e');
    }
  }
  
  @override
  Future<void> resetUri() async {
    uri = 'https://api.openai.com/v1/';

    await updateOptions();
    notifyListeners();
  }

  @override
  void save() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("open_ai_model", json.encode(toMap()));
    });
  }
}