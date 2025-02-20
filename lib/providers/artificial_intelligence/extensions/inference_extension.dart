part of 'package:maid/main.dart';

extension InferenceExtension on ArtificialIntelligence {
  Future<void> prompt(String message) async {
    root.chain.last.addChild(UserChatMessage(message));

    busy = true;
    notify();

    Stream<String> stream;
    switch (ecosystem) {
      case LlmEcosystem.llamaCPP:
        stream = llamaPrompt(root.chainData.copy());
        break;
      case LlmEcosystem.ollama:
        stream = ollamaPrompt(root.chainData.copy());
        break;
      case LlmEcosystem.openAI:
        stream = openAiPrompt(root.chainData.copy());
        break;
      case LlmEcosystem.mistral:
        stream = mistralPrompt(root.chainData.copy());
        break;
    }

    root.chain.last.addChild(AssistantChatMessage(''));
    notify();

    try {
      await for (final response in stream) {
        root.chain.last.data.content += response;
        notify();
      }
    }
    finally {
      busy = false;
      saveAndNotify();
    }
  }

  Future<void> regenerate(GeneralTreeNode<ChatMessage> node) async {
    busy = true;
    notify();

    if (_ecosystem == LlmEcosystem.llamaCPP) {
      reloadModel();
      assert(_llama != null);
    }

    node.addChild(AssistantChatMessage(''));
    notify();

    assert(root.chainData.last is AssistantChatMessage);

    final chainData = root.chainData.copy();
    chainData.removeLast();

    Stream<String> stream;
    switch (ecosystem) {
      case LlmEcosystem.llamaCPP:
        stream = llamaPrompt(chainData);
        break;
      case LlmEcosystem.ollama:
        stream = ollamaPrompt(chainData);
        break;
      case LlmEcosystem.openAI:
        stream = openAiPrompt(chainData);
        break;
      case LlmEcosystem.mistral:
        stream = mistralPrompt(chainData);
        break;
    }

    assert(node.currentChild == root.chain.last);

    try {
      await for (final response in stream) {
        root.chain.last.data.content += response;
        notify();
      }
    }
    finally {
      busy = false;
      saveAndNotify();
    }
  }

  void stop() async {
    switch (ecosystem) {
      case LlmEcosystem.llamaCPP:
        _llama?.stop();
        break;
      case LlmEcosystem.ollama:
        _ollamaClient.endSession();
        break;
      case LlmEcosystem.openAI:
        _openAiClient.endSession();
        break;
      case LlmEcosystem.mistral:
        _mistralClient.endSession();
        break;
    }


    busy = false;
    saveAndNotify();
  }
}