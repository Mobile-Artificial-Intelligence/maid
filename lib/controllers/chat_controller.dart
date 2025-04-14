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

  List<GeneralTreeNode<LlamaMessage>> _chats = [];

  List<GeneralTreeNode<LlamaMessage>> get chats => _chats;

  set chats(List<GeneralTreeNode<LlamaMessage>> newChats) {
    _chats = newChats;
    notifyListeners();
  }

  GeneralTreeNode<LlamaMessage> get root {
    if (_chats.isEmpty) {
      final chat = GeneralTreeNode<LlamaMessage>(SystemLlamaMessage('New Chat'));
      _chats.add(chat);
    }

    return _chats.first;
  }

  set root(GeneralTreeNode<LlamaMessage> newRoot){
    _chats.remove(newRoot);

    _chats.insert(0, newRoot);

    save();
    notifyListeners();
  }

  void newChat() {
    final chat = GeneralTreeNode<LlamaMessage>(SystemLlamaMessage('New Chat'));

    _chats.insert(0, chat);
    
    save();
    notifyListeners();
  }

  void deleteChat(GeneralTreeNode<LlamaMessage> chat) {
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
      final chatMap = jsonDecode(chatString);
      final chat = GeneralTreeNode.fromMap(chatMap, LlamaMessage.fromMap);

      _chats.insert(0, chat);
      save();
      notifyListeners();
    }
  }

  void exportChat(GeneralTreeNode<LlamaMessage> chat) async {
    final chatMap = chat.toMap(LlamaMessage.messageToMap);
    final chatString = jsonEncode(chatMap);

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

  void addToEnd(LlamaMessage message) {
    root.chain.last.addChild(message);
    save();
    notifyListeners();
  }

  Future<void> streamToEnd(Stream<String> stream) async {
    root.chain.last.addChild(AssistantLlamaMessage(''));
    notifyListeners();

    await for (final response in stream) {
      root.chain.last.data.content += response;
      notifyListeners();
    }

    save();
    notifyListeners();
  }

  Future<void> streamToChild(GeneralTreeNode<LlamaMessage> node, Stream<String> stream) async {
    notifyListeners();
    
    await for (final response in stream) {
      node.currentChild!.data.content += response;
      notifyListeners();
    }

    save();
    notifyListeners();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final chatsStrings = prefs.getStringList('chats') ?? [];

    _chats.clear();
    for (final chatString in chatsStrings) {
      final chatMap = jsonDecode(chatString);
      final chat = GeneralTreeNode.fromMap(chatMap, LlamaMessage.fromMap);
      _chats.add(chat);
    }

    if (_chats.isEmpty) {
      final chat = GeneralTreeNode<LlamaMessage>(SystemLlamaMessage('New Chat'));
      _chats.add(chat);
    }

    notifyListeners();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> chatsStrings = [];

    for (final chat in _chats) {
      final chatMap = chat.toMap(LlamaMessage.messageToMap);
      final chatString = jsonEncode(chatMap);
      chatsStrings.add(chatString);
    }

    await prefs.setStringList('chats', chatsStrings);
  }
}