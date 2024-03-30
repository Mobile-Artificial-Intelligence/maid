import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:maid/classes/large_language_model.dart';
import 'package:maid/static/logger.dart';

class OpenAiModel extends LargeLanguageModel {
  @override
  AiPlatformType get type => AiPlatformType.openAI;

  OpenAiModel({
    super.name,
    super.uri = 'https://api.openai.com/v1/',
    super.token,
    super.seed,
    super.nPredict,
    super.topP,
    super.penaltyPresent,
    super.penaltyFreq,
  });

  OpenAiModel.fromMap(Map<String, dynamic> json) {
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
  }

  @override
  Map<String, dynamic> toMap() {
    return super.toMap();
  }

  @override
  Stream<String> prompt(List<ChatMessage> messages) async* {
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
    return ["gpt-3.5-turbo", "gpt-4-32k"];
  }
  
  @override
  Future<void> resetUri() async {
    uri = 'https://api.openai.com/v1/';
  }
}