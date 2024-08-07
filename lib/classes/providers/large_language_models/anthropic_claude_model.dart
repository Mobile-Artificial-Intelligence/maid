import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:maid/classes/chat_node.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/enumerators/large_language_model_type.dart';
import 'package:maid/classes/static/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClaudeModel extends LargeLanguageModel {
  static const String defaultUrl = 'https://api.anthropic.com';

  @override
  LargeLanguageModelType get type => LargeLanguageModelType.mistralAI;

  static ClaudeModel of(BuildContext context) => LargeLanguageModel.of(context) as ClaudeModel;

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
    if ((uri == defaultUrl && token.isEmpty) || uri.isEmpty) {
      return [];
    }
    
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
    name = '';
    notifyListeners();
  }

  @override
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("anthropic_model", json.encode(toMap()));
  }

  @override
  void reset() {
    fromMap({});
  }
}