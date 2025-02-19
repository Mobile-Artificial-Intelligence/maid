part of 'package:maid/main.dart';

extension OpenAiExtension on ArtificialIntelligence {
  Stream<String> openAiPrompt(List<ChatMessage> messages) async* {
    assert(apiKey[LlmEcosystem.openAI] != null);
    assert(model[LlmEcosystem.openAI] != null);

    if (baseUrl[LlmEcosystem.openAI] == null || baseUrl[LlmEcosystem.openAI]!.isEmpty) {
      setBaseUrl(LlmEcosystem.openAI, 'https://api.openai.com/v1');
    }

    _openAiClient = open_ai.OpenAIClient(
      apiKey: apiKey[LlmEcosystem.openAI]!,
      baseUrl: baseUrl[LlmEcosystem.openAI],
    );

    final completionStream = _openAiClient.createChatCompletionStream(
      request: open_ai.CreateChatCompletionRequest(
        messages: messages.toOpenAiMessages(),
        model: open_ai.ChatCompletionModel.modelId(model[LlmEcosystem.openAI]!),
        stream: true,
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
    if (apiKey[LlmEcosystem.openAI] == null) {
      log('Open AI API Key is not set');
      return [];
    }

    if (baseUrl[LlmEcosystem.openAI] == null || baseUrl[LlmEcosystem.openAI]!.isEmpty) {
      baseUrl[LlmEcosystem.openAI] = 'https://api.openai.com/v1';
    }

    _openAiClient = open_ai.OpenAIClient(
      apiKey: apiKey[LlmEcosystem.openAI]!,
      baseUrl: baseUrl[LlmEcosystem.openAI],
    );

    final modelsResponse = await _openAiClient.listModels();

    return modelsResponse.data.map((model) => model.id).toList();
  }
}