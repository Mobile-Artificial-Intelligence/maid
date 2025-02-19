part of 'package:maid/main.dart';

extension OpenAiExtension on ArtificialIntelligence {
  Stream<String> openAiPrompt(List<ChatMessage> messages) async* {
    assert(apiKey[LlmEcosystem.openAI] != null);
    assert(model[LlmEcosystem.openAI] != null);

    _openAiClient = openAI.OpenAIClient(
      apiKey: apiKey[LlmEcosystem.openAI]!,
      baseUrl: baseUrl[LlmEcosystem.openAI],
    );

    final completionStream = _openAiClient.createChatCompletionStream(
      request: openAI.CreateChatCompletionRequest(
        messages: messages.toOpenAiMessages(),
        model: openAI.ChatCompletionModel.modelId(model[LlmEcosystem.openAI]!),
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
        log(e.toString());
      }
    }
  }
}