import 'dart:convert';
import 'dart:ui';

import 'package:http/http.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_mistralai/langchain_mistralai.dart';
import 'package:maid/classes/large_language_model.dart';
import 'package:maid/static/logger.dart';
import 'package:maid/classes/chat_node.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MistralAiModel extends LargeLanguageModel {
  static const String defaultUrl = 'https://api.mistral.ai';

  @override
  LargeLanguageModelType get type => LargeLanguageModelType.mistralAI;

  MistralAiModel({
    super.listener, 
    super.name,
    super.uri = defaultUrl,
    super.token,
    super.useDefault,
    super.seed,
    super.temperature,
    super.topP
  });

  MistralAiModel.fromMap(VoidCallback listener, Map<String, dynamic> json) {
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
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
    };
  }

  @override
  Stream<String> prompt(List<ChatNode> messages) async* {
    List<ChatMessage> chatMessages = [];

    for (var message in messages) {
      Logger.log("Message: ${message.content}");
      if (message.content.isEmpty) {
        continue;
      }

      switch (message.role) {
        case ChatRole.user:
          chatMessages.add(ChatMessage.humanText(message.content));
          break;
        case ChatRole.assistant:
          chatMessages.add(ChatMessage.ai(message.content));
          break;
        case ChatRole.system: // Under normal circumstances, this should only be used for preprompt
          chatMessages.add(ChatMessage.system(message.content));
          break;
        default:
          break;
      }
    }
    
    try {
      final chat = ChatMistralAI(
        baseUrl: '$uri/v1',
        apiKey: token,
        defaultOptions: ChatMistralAIOptions(
          model: name,
          topP: topP,
          temperature: temperature,
        ),
      );

      final stream = chat.stream(PromptValue.chat(chatMessages));

      yield* stream.map((final res) => res.output.content);
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