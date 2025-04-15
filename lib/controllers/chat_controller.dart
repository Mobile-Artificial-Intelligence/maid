part of 'package:maid/main.dart';

class ChatController extends ChangeNotifier {
  static ChatController? _instance;
  static ChatController get instance {
    _instance ??= ChatController();
    return _instance!;
  }

  ChatController() {
    load();
  }

  List<ChatMessage> _chats = [];

  List<ChatMessage> get chats => _chats;

  set chats(List<ChatMessage> newChats) {
    _chats = newChats;
    notifyListeners();
  }

  ChatMessage get root {
    if (_chats.isEmpty) {
      final chat = ChatMessage(role: ChatMessageRole.system, content: 'New Chat');
      _chats.add(chat);
    }

    return _chats.first;
  }

  set root(ChatMessage newRoot){
    _chats.remove(newRoot);

    _chats.insert(0, newRoot);

    save();
    notifyListeners();
  }

  void newChat() {
    final chat = ChatMessage(role: ChatMessageRole.system, content: 'New Chat');

    _chats.insert(0, chat);
    
    save();
    notifyListeners();
  }

  void deleteChat(ChatMessage chat) {
    _chats.remove(chat);
    save();
    notifyListeners();
  }

  void importChat() async {
    final inputFile = await FilePicker.platform.pickFiles(
      dialogTitle: 'Import Chat',
      type: FileType.custom,
      allowedExtensions: ['json']
    );

    if (inputFile != null) {
      final bytes = inputFile.files.single.bytes ?? File(inputFile.files.single.path!).readAsBytesSync();
      final chatString = utf8.decode(bytes);
      final chatMapList = jsonDecode(chatString);
      final chat = ChatMessage.fromMapList(chatMapList);

      _chats.insert(0, chat);
      save();
      notifyListeners();
    }
  }

  void exportChat(ChatMessage chat) async {
    final chatMapList = chat.toMapList();
    final chatString = jsonEncode(chatMapList);

    final outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Export Chat',
      fileName: 'chat.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: utf8.encode(chatString)
    );

    if (outputFile != null && !File(outputFile).existsSync()) {
      await File(outputFile).writeAsString(chatString);
    }
  }

  void clear() {
    _chats.clear();
    save();
    notifyListeners();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final chatsStrings = prefs.getStringList('chats') ?? [];

    _chats.clear();
    for (final chatString in chatsStrings) {
      final chatMapList = (jsonDecode(chatString) as List).cast<Map<String, dynamic>>();
      final chat = ChatMessage.fromMapList(chatMapList);
      _chats.add(chat);
    }

    if (_chats.isEmpty) {
      final chat = ChatMessage(role: ChatMessageRole.system, content: 'New Chat');
      _chats.add(chat);
    }

    notifyListeners();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> chatsStrings = [];

    for (final chat in _chats) {
      final chatMap = chat.toMapList();
      final chatString = jsonEncode(chatMap);
      chatsStrings.add(chatString);
    }

    await prefs.setStringList('chats', chatsStrings);
  }
}