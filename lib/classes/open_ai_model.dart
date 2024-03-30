import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:maid/classes/large_language_model.dart';
import 'package:maid/static/logger.dart';

class OpenAiModel extends LargeLanguageModel {
  late String name;
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
    this.name = '',
    this.url = '',
    this.token = '',
    this.nPredict = 512,
    this.topP = 0.95,
    this.penaltyPresent = 0.0,
    this.penaltyFreq = 0.0
  });

  OpenAiModel.fromJson(Map<String, dynamic> json) {
    fromJson(json);
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    useDefault = json['useDefault'] ?? true;
    name = json['name'] ?? '';
    url = json['url'] ?? '';
    token = json['token'] ?? '';
    nPredict = json['nPredict'] ?? 512;
    topP = json['topP'] ?? 0.95;
    penaltyPresent = json['penaltyPresent'] ?? 0.0;
    penaltyFreq = json['penaltyFreq'] ?? 0.0;
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
          topP: topP,
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