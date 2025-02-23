part of 'package:maid/main.dart';

class ChatController extends ChangeNotifier {
  ChatController() {
    load();
  }

  void notify() {
    notifyListeners();
  }

  void saveAndNotify() {
    save();
    notifyListeners();
  }

  List<GeneralTreeNode<ChatMessage>> _chats = [];

  List<GeneralTreeNode<ChatMessage>> get chats => _chats;

  set chats(List<GeneralTreeNode<ChatMessage>> newChats) {
    _chats = newChats;
    notifyListeners();
  }

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

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final chatsStrings = prefs.getStringList('chats') ?? [];

    _chats.clear();
    for (final chatString in chatsStrings) {
      final chatMap = jsonDecode(chatString);
      final chat = GeneralTreeNode.fromMap(chatMap, ChatMessage.fromMap);
      _chats.add(chat);
    }

    if (_chats.isEmpty) {
      final chat = GeneralTreeNode<ChatMessage>(SystemChatMessage('New Chat'));
      _chats.add(chat);
    }

    notifyListeners();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> chatsStrings = [];

    for (final chat in _chats) {
      final chatMap = chat.toMap(ChatMessage.messageToMap);
      final chatString = jsonEncode(chatMap);
      chatsStrings.add(chatString);
    }

    await prefs.setStringList('chats', chatsStrings);
  }
}