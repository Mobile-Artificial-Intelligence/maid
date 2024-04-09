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
      final url = Uri.parse('$uri/v1/completions');
      
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
    options = ["gpt-3.5-turbo", "gpt-4-32k"];
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