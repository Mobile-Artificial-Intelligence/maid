part of 'package:maid/main.dart';

extension InferenceExtension on ArtificialIntelligence {
  Stream<String> promptSwitch(List<ChatMessage> messages) async* {
    switch (ecosystem) {
      case LlmEcosystem.llamaCPP:
        yield* llamaPrompt(messages);
        break;
      case LlmEcosystem.ollama:
        yield* ollamaPrompt(messages);
        break;
      default:
        throw Exception('Invalid ecosystem');
    }
  }
  
  void prompt(String message) async {
    root.chain.last.addChild(UserChatMessage(message));

    busy = true;
    notify();

    Stream<String> stream = promptSwitch(root.chainData.copy());

    root.chain.last.addChild(AssistantChatMessage(''));
    notify();

    await for (final response in stream) {
      root.chain.last.data.content += response;
      notify();
    }

    await save();

    busy = false;
    notify();
  }

  void regenerate(GeneralTreeNode<ChatMessage> node) async {
    busy = true;
    notify();

    if (_ecosystem == LlmEcosystem.llamaCPP) {
      reloadModel();
      assert(_llama != null);
    }

    final chainData = root.chainData.copy();
    if (chainData.last is AssistantChatMessage) {
      chainData.removeLast();
    }

    final stream = promptSwitch(chainData);

    assert(node.currentChild == root.chain.last);

    await for (final response in stream) {
      root.chain.last.data.content += response;
      notify();
    }

    await save();

    busy = false;
    notify();
  }

  void stop() async {
    switch (ecosystem) {
      case LlmEcosystem.llamaCPP:
        _llama?.stop();
        break;
      case LlmEcosystem.ollama:
        _ollamaClient.endSession();
        break;
      default:
        throw Exception('Invalid ecosystem');
    }


    await save();
    busy = false;
    notify();
  }
}