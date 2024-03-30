import 'package:langchain/langchain.dart';
import 'package:langchain_mistralai/langchain_mistralai.dart';
import 'package:maid/classes/large_language_model.dart';
import 'package:maid/static/logger.dart';

class MistralAiModel extends LargeLanguageModel {
  @override
  AiPlatformType get type => AiPlatformType.mistralAI;

  MistralAiModel({
    super.name,
    super.uri = 'https://api.mistral.ai/v1/',
    super.token,
    super.useDefault,
    super.seed,
    super.temperature,
    super.topP
  });

  MistralAiModel.fromMap(Map<String, dynamic> json) {
    fromMap(json);
  }

  @override
  void fromMap(Map<String, dynamic> json) {
    super.fromMap(json);
    uri = json['url'] ?? 'https://api.mistral.ai/v1/';
    token = json['token'] ?? '';
    topP = json['topP'] ?? 0.95;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
    };
  }

  @override
  Stream<String> prompt(List<ChatMessage> messages) async* {
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

      final stream = chat.stream(PromptValue.chat(messages));

      await for (final ChatResult response in stream) {
        yield response.firstOutputAsString;
      }
    } catch (e) {
      Logger.log('Error: $e');
    }
  }
  
  @override
  Future<List<String>> getOptions() async {
    return ["mistral-small", "mistral-medium", "mistral-large"];
  }
  
  @override
  Future<void> resetUri() async {
    uri = 'https://api.mistral.ai/v1/';
  }
}