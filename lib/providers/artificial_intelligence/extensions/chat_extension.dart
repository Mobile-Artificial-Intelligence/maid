part of 'package:maid/main.dart';

extension ChatExtension on ArtificialIntelligenceProvider {
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
    
    if (_aiNotifier is LlamaCppNotifier) {
      (_aiNotifier as LlamaCppNotifier).reloadModel();
    }

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
}