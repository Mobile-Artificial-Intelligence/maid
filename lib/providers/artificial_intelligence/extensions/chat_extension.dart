part of 'package:maid/main.dart';

extension ChatExtension on ArtificialIntelligence {
  GeneralTreeNode<ChatMessage> get root => _chats.isNotEmpty ? 
    _chats.first : GeneralTreeNode<ChatMessage>(SystemChatMessage('New Chat'));

  set root(GeneralTreeNode<ChatMessage> newRoot){
    _chats.remove(newRoot);

    _chats.insert(0, newRoot);
    
    reloadModel();

    notify();
  }

  void newChat() {
    final chat = GeneralTreeNode<ChatMessage>(SystemChatMessage('New Chat'));

    _chats.insert(0, chat);
    
    save();
    notify();
  }

  void deleteChat(GeneralTreeNode<ChatMessage> chat) {
    _chats.remove(chat);
    save();
    notify();
  }

  void clearChats() {
    _chats.clear();
    save();
    notify();
  }
}