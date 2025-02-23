part of 'package:maid/main.dart';

extension InferenceExtension on MaidContext {
  Future<void> prompt(String message) async {
    root.chain.last.addChild(UserChatMessage(message));
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
      saveAndNotify();
    }
  }

  Future<void> regenerate(GeneralTreeNode<ChatMessage> node) async {
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
      saveAndNotify();
    }
  }

  void stop() {
    _aiNotifier.stop();
    saveAndNotify();
  }
}