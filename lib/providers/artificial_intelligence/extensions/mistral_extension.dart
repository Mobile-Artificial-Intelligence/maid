part of 'package:maid/main.dart';

extension MistralExtension on ArtificialIntelligence {
  Stream<String> mistralPrompt(List<ChatMessage> messages) async* {
    assert(apiKey[LlmEcosystem.mistral] != null);
    assert(model[LlmEcosystem.mistral] != null);

    if (baseUrl[LlmEcosystem.mistral] == null || baseUrl[LlmEcosystem.mistral]!.isEmpty) {
      setBaseUrl(LlmEcosystem.mistral, 'https://api.mistral.ai/v1');
    }

    _mistralClient = mistral.MistralAIClient(
      apiKey: apiKey[LlmEcosystem.mistral]!,
      baseUrl: baseUrl[LlmEcosystem.mistral],
    );

    mistral.ChatCompletionModels mistralModel;

    if (model[LlmEcosystem.mistral] == 'mistral-medium') {
      mistralModel = mistral.ChatCompletionModels.mistralMedium;
    } 
    else if (model[LlmEcosystem.mistral] == 'mistral-small') {
      mistralModel = mistral.ChatCompletionModels.mistralSmall;
    } 
    else if (model[LlmEcosystem.mistral] == 'mistral-tiny') {
      mistralModel = mistral.ChatCompletionModels.mistralTiny;
    } 
    else {
      throw Exception('Unknown Mistral model: ${model[LlmEcosystem.mistral]}');
    }

    final completionStream = _mistralClient.createChatCompletionStream(
      request: mistral.ChatCompletionRequest(
        messages: messages.toMistralMessages(),
        model: mistral.ChatCompletionModel.model(mistralModel),
        stream: true,
        temperature: overrides['temperature'],
        topP: overrides['top_p'],
        maxTokens: overrides['max_tokens'],
        randomSeed: overrides['seed'],
      )
    );

    try {
      await for (final completion in completionStream) {
        yield completion.choices.first.delta.content ?? '';
      }
    }
    catch (e) {
      // This is expected when the user presses stop
      if (!e.toString().contains('Connection closed')) {
        rethrow;
      }
    }
  }

  Future<List<String>> getMistralModelOptions() async => [
    'mistral-medium',
    'mistral-small',
    'mistral-tiny',
  ];
}