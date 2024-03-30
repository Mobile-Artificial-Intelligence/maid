import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:maid/classes/large_language_model.dart';
import 'package:maid/static/logger.dart';

class OpenAiModel extends LargeLanguageModel {
  @override
  AiPlatformType get type => AiPlatformType.openAI;

  late String url;
  late String token;

  late int nPredict;
  late double topP;
  late double penaltyPresent;
  late double penaltyFreq;

  OpenAiModel({
    super.useDefault,
    super.seed,
    super.temperature,
    super.name,
    this.url = 'https://api.openai.com/v1/',
    this.token = '',
    this.nPredict = 512,
    this.topP = 0.95,
    this.penaltyPresent = 0.0,
    this.penaltyFreq = 0.0
  });

  OpenAiModel.fromMap(Map<String, dynamic> json) {
    fromMap(json);
  }

  @override
  void fromMap(Map<String, dynamic> json) {
    super.fromMap(json);
    url = json['url'] ?? 'https://api.openai.com/v1/';
    token = json['token'] ?? '';
    nPredict = json['nPredict'] ?? 512;
    topP = json['topP'] ?? 0.95;
    penaltyPresent = json['penaltyPresent'] ?? 0.0;
    penaltyFreq = json['penaltyFreq'] ?? 0.0;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'url': url,
      'token': token,
      'nPredict': nPredict,
      'topP': topP,
      'penaltyPresent': penaltyPresent,
      'penaltyFreq': penaltyFreq
    };
  }

  @override
  Stream<String> prompt(List<ChatMessage> messages) async* {
    try {
      final chat = ChatOpenAI(
        baseUrl: url,
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
  Future<void> resetUrl() async {
    url = 'https://api.openai.com/v1/';
  }
}