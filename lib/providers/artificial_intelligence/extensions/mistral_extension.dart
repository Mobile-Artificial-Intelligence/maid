part of 'package:maid/main.dart';

extension MistralExtension on ArtificialIntelligence {
  Stream<String> mistralPrompt(List<ChatMessage> messages) async* {
    assert(ecosystem == ArtificialIntelligenceEcosystem.mistral);
    assert(remoteContext != null);
    assert(apiKey != null);
    assert(model != null);

    if (baseUrl == null || baseUrl!.isEmpty) {
      remoteContext!.baseUrl = 'https://api.mistral.ai/v1';
    }

    _mistralClient = mistral.MistralAIClient(
      apiKey: apiKey!,
      baseUrl: baseUrl,
    );

    mistral.ChatCompletionModels mistralModel;

    if (model == 'mistral-medium') {
      mistralModel = mistral.ChatCompletionModels.mistralMedium;
    } 
    else if (model == 'mistral-small') {
      mistralModel = mistral.ChatCompletionModels.mistralSmall;
    } 
    else if (model == 'mistral-tiny') {
      mistralModel = mistral.ChatCompletionModels.mistralTiny;
    } 
    else {
      throw Exception('Unknown Mistral model: $model');
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