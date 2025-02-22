part of 'package:maid/main.dart';

extension InferenceExtension on ArtificialIntelligenceProvider {
  Future<void> prompt(String message) async {
    root.chain.last.addChild(UserChatMessage(message));

    busy = true;
    notify();

    Stream<String> stream = _aiNotifier.prompt(root.chainData.copy());

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
    node.addChild(AssistantChatMessage(''));
    notify();

    if (llamaCppNotifier != null) {
      llamaCppNotifier!.reloadModel(true);
    }

    assert(root.chainData.last is AssistantChatMessage);

    final chainData = root.chainData.copy();
    chainData.removeLast();

    Stream<String> stream = _aiNotifier.prompt(chainData);

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

  void stop() {
    _aiNotifier.stop();
    busy = false;
    saveAndNotify();
  }
}