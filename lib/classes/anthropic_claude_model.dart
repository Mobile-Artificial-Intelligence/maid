import 'dart:convert';
import 'dart:ui';

import 'package:http/http.dart';
import 'package:maid/classes/chat_node.dart';
import 'package:maid/classes/large_language_model.dart';
import 'package:maid/static/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClaudeModel extends LargeLanguageModel {
  static const String defaultUrl = 'https://api.anthropic.com';

  @override
  LargeLanguageModelType get type => LargeLanguageModelType.mistralAI;

  ClaudeModel({
    super.listener, 
    super.name,
    super.uri = defaultUrl,
    super.token,
    super.useDefault,
    super.seed,
    super.temperature,
    super.topK,
    super.topP
  });

  ClaudeModel.fromMap(VoidCallback listener, Map<String, dynamic> json) {
    addListener(listener);
    fromMap(json);
  }

  @override
  void fromMap(Map<String, dynamic> json) {
    if (json['uri'] == null) json['uri'] = defaultUrl;
    super.fromMap(json);
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
      final url = Uri.parse('$uri/v1/messages');
      
      final headers = {
        'x-api-key': token,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      };

      final body = {
        'model': name,
        'messages': chat,
        'temperature': temperature,
        'top_k': topK,
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
  Future<List<String>> get options async {
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
          return models.map((model) => model['id'] as String).toList();
        } else {
          throw Exception('Model Data is null');
        }
      } else {
        throw Exception('Failed to update options: ${response.statusCode}');
      }
    } catch (e) {
      Logger.log('Error: $e');
      return [];
    }
  }
  
  @override
  Future<void> resetUri() async {
    uri = defaultUrl;
    notifyListeners();
  }

  @override
  void save() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("mistral_ai_model", json.encode(toMap()));
    });
  }

  @override
  void reset() {
    fromMap({});
  }
}