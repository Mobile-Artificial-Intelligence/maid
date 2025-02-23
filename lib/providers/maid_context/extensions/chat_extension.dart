part of 'package:maid/main.dart';

extension ChatExtension on MaidContext {
  GeneralTreeNode<ChatMessage> get root {
    if (_chats.isEmpty) {
      final chat = GeneralTreeNode<ChatMessage>(SystemChatMessage('New Chat'));
      _chats.add(chat);
    }

    return _chats.first;
  }

  set root(GeneralTreeNode<ChatMessage> newRoot){
    _chats.remove(newRoot);

    _chats.insert(0, newRoot);

    saveAndNotify();
  }

  void newChat() {
    final chat = GeneralTreeNode<ChatMessage>(SystemChatMessage('New Chat'));

    _chats.insert(0, chat);
    
    saveAndNotify();
  }

  void deleteChat(GeneralTreeNode<ChatMessage> chat) {
    _chats.remove(chat);
    saveAndNotify();
  }

  void clearChats() {
    _chats.clear();
    saveAndNotify();
  }

  void addToEnd(ChatMessage message) {
    root.chain.last.addChild(message);
    saveAndNotify();
  }

  Future<void> streamToEnd(Stream<String> stream) async {
    root.chain.last.addChild(AssistantChatMessage(''));
    notify();

    await for (final response in stream) {
      root.chain.last.data.content += response;
      notify();
    }

    saveAndNotify();
  }

  Future<void> streamToChild(GeneralTreeNode<ChatMessage> node, Stream<String> stream) async {
    notify();
    
    await for (final response in stream) {
      node.currentChild!.data.content += response;
      notify();
    }

    saveAndNotify();
  }
}