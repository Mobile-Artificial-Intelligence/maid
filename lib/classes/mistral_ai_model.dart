import 'package:langchain/langchain.dart';
import 'package:langchain_mistralai/langchain_mistralai.dart';
import 'package:maid/classes/large_language_model.dart';
import 'package:maid/static/logger.dart';

class MistralAiModel extends LargeLanguageModel {
  late String name;
  late String url;
  late String token;
  late double topP;

  MistralAiModel({
    super.useDefault,
    super.seed,
    super.temperature,
    this.name = '',
    this.url = '',
    this.token = '',
    this.topP = 0.95
  });

  MistralAiModel.fromJson(Map<String, dynamic> json) {
    fromJson(json);
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    name = json['name'] ?? '';
    url = json['url'] ?? '';
    token = json['token'] ?? '';
    topP = json['topP'] ?? 0.95;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'name': name,
      'url': url,
      'token': token,
      'topP': topP
    };
  }

  @override
  Stream<String> prompt(List<ChatMessage> messages) async* {
    try {
      final chat = ChatMistralAI(
        baseUrl: '$url/v1',
        apiKey: token,
        defaultOptions: ChatMistralAIOptions(
          model: name,
          topP: topP,
          temperature: temperature,
        ),
      );

      final stream = chat.stream(PromptValue.chat(messages));

      await for (final ChatResult response in stream) {
        yield response.firstOutputAsString;
      }
    } catch (e) {
      Logger.log('Error: $e');
    }
  }
}