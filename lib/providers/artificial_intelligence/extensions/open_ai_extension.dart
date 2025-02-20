part of 'package:maid/main.dart';

extension OpenAiExtension on ArtificialIntelligence {
  Stream<String> openAiPrompt(List<ChatMessage> messages) async* {
    assert(remoteContext != null);
    assert(apiKey != null);
    assert(model != null);

    if (baseUrl == null || baseUrl!.isEmpty) {
      remoteContext!.baseUrl = 'https://api.openai.com/v1';
    }

    _openAiClient = open_ai.OpenAIClient(
      apiKey: apiKey!,
      baseUrl: baseUrl,
    );

    final completionStream = _openAiClient.createChatCompletionStream(
      request: open_ai.CreateChatCompletionRequest(
        messages: messages.toOpenAiMessages(),
        model: open_ai.ChatCompletionModel.modelId(model!),
        stream: true,
        temperature: overrides['temperature'],
        topP: overrides['top_p'],
        maxTokens: overrides['max_tokens'],
        frequencyPenalty: overrides['frequency_penalty'],
        presencePenalty: overrides['presence_penalty'],
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

  Future<List<String>> getOpenAiModelOptions() async {
    assert(ecosystem == ArtificialIntelligenceEcosystem.openAI);
    assert(remoteContext != null);

    if (apiKey == null) {
      log('Open AI API Key is not set');
      return [];
    }

    if (baseUrl == null || baseUrl!.isEmpty) {
      remoteContext!.baseUrl = 'https://api.openai.com/v1';
    }

    _openAiClient = open_ai.OpenAIClient(
      apiKey: apiKey!,
      baseUrl: baseUrl,
    );

    final modelsResponse = await _openAiClient.listModels();

    return modelsResponse.data.map((model) => model.id).toList();
  }
}