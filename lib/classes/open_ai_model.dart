import 'dart:convert';
import 'dart:ui';

import 'package:http/http.dart';
import 'package:langchain_openai/langchain_openai.dart';
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
    super.uri = 'https://api.openai.com/v1',
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
    uri = json['url'] ?? 'https://api.openai.com/v1';
    token = json['token'] ?? '';
    nPredict = json['nPredict'] ?? 512;
    topP = json['topP'] ?? 0.95;
    penaltyPresent = json['penaltyPresent'] ?? 0.0;
    penaltyFreq = json['penaltyFreq'] ?? 0.0;
    notifyListeners();
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
      final chat = ChatOpenAI(
        baseUrl: uri,
        apiKey: token,
        defaultOptions: ChatOpenAIOptions(
          model: name,
          temperature: temperature,
          frequencyPenalty: penaltyFreq,
          presencePenalty: penaltyPresent,
          maxTokens: nPredict,
          topP: topP
        )
      );

      final stream = chat.stream(PromptValue.chat(chatMessages));

      await for (final ChatResult response in stream) {
        yield response.firstOutputAsString;
      }
    } catch (e) {
      Logger.log('Error: $e');
    }
  }
  
  @override
  Future<void> updateOptions() async {
    try {
      final url = Uri.parse('$uri/models');

      final headers = {
        'Content-Type': 'application/json',
        'Accept':'application/json',
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
    uri = 'https://api.openai.com/v1';

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