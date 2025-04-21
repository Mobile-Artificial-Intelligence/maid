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

  ValueKey<String>? _rootKey;

  Map<ValueKey<String>, ChatMessage> _mapping = {};

  Map<ValueKey<String>, ChatMessage> get mapping => _mapping;

  set mapping(Map<ValueKey<String>, ChatMessage> newMapping) {
    _mapping = newMapping;
    notifyListeners();
  }

  List<ValueKey<String>> get roots {
    return _mapping.keys.where((key) => _mapping[key]!.parent == null).toList();
  }

  ChatMessage get root {
    if (_mapping.isEmpty || _rootKey == null || !_mapping.containsKey(_rootKey)) {
      final chat = ChatMessage(role: ChatMessageRole.system, content: 'New Chat');
      _mapping[chat.id] = chat;
      _rootKey = chat.id;
    }

    return _mapping[_rootKey]!;
  }

  set root(ChatMessage newRoot){
    _mapping[newRoot.id] = newRoot;
    _rootKey = newRoot.id;

    save();
    notifyListeners();
  }

  void addMessage(ChatMessage message) {
    _mapping[message.id] = message;

    save();
    notifyListeners();
  }

  void deleteMessage(ChatMessage message) async {
    _mapping.remove(message.id);

    save();
    notifyListeners();
  }

  void newChat() {
    final chat = ChatMessage(role: ChatMessageRole.system, content: 'New Chat');
    _mapping[chat.id] = chat;
    _rootKey = chat.id;
    
    save();
    notifyListeners();
  }

  void deleteChat(ChatMessage chat) {
    final chatRoot = chat.root; // Ensures we delete the root chat

    deleteMessage(chatRoot);

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
      List<Map<String, dynamic>> data = (jsonDecode(chatString) as List).cast<Map<String, dynamic>>();
      if (data.isEmpty) return;

      if (data.first['mapping'] != null) {
        data = OpenAiUtilities.openAiMapper(data);
      }

      _mapping.clear();
      for (final chatMap in data) {
        final chat = ChatMessage.fromMap(chatMap);
        _mapping[chat.id] = chat;
      }
      _rootKey = _mapping.keys.firstWhere((key) => _mapping[key]!.parent == null);

      save();
      notifyListeners();
    }
  }

  void exportChat(ChatMessage chat) async {
    List<Map<String, dynamic>> chatMapList = [];

    for (final msg in chat.root.chain) {
      chatMapList.add(msg.toMap());
    }

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
    _mapping.clear();
    save();
    notifyListeners();
  }

  Future<void> load() async {
    if (Supabase.instance.client.auth.currentUser != null) {
      await loadSupabase();

      if (_mapping.isNotEmpty) return;
    }

    await loadSharedPrefs();
  }

  Future<void> loadSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final chatsStrings = prefs.getStringList('chat_messages') ?? [];

    _mapping.clear();
    for (final chatString in chatsStrings) {
      final chatMap = jsonDecode(chatString);
      final chat = ChatMessage.fromMap(chatMap);
      _mapping[chat.id] = chat;
    }

    if (_mapping.isEmpty) {
      final chat = ChatMessage(role: ChatMessageRole.system, content: 'New Chat');
      _mapping[chat.id] = chat;
      _rootKey = chat.id;
    }

    notifyListeners();
  }

  Future<void> loadSupabase() async {
    if (Supabase.instance.client.auth.currentUser == null) throw Exception('User not logged in');

    const pageSize = 1000;
    int offset = 0;
    List<Map<String, dynamic>> data = [];

    while (true) {
      final page = await Supabase.instance.client
          .from('chat_messages')
          .select('*')
          .range(offset, offset + pageSize - 1);

      if (page.isEmpty) break;

      data.addAll(page);
      if (page.length < pageSize) break;
      offset += pageSize;
    }

    if (data.isEmpty) return;

    _mapping.clear();
    for (final chatMap in data) {
      final chat = ChatMessage.fromMap(chatMap);
      _mapping[chat.id] = chat;
    }
    _rootKey = _mapping.keys.firstWhere((key) => _mapping[key]!.parent == null);

    notifyListeners();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> chatsStrings = [];
    List<Map<String, dynamic>> messages = [];

    for (final chat in _mapping.values) {
      final chatMap = chat.toMap();
      messages.add(chatMap);

      final chatString = jsonEncode(chatMap);
      chatsStrings.add(chatString);
    }

    await prefs.setStringList('chat_messages', chatsStrings);

    if (Supabase.instance.client.auth.currentUser == null) return;

    final userId = Supabase.instance.client.auth.currentUser!.id;

    for (final msg in messages) {
      await Supabase.instance.client.from('chat_messages').upsert({
        'id': msg['id'],
        'user_id': userId,
        'role': msg['role'],
        'content': msg['content'],
        'parent': msg['parent'],
        'create_time': msg['create_time'],
        'update_time': msg['update_time'],
      });
    }

    for (final msg in messages) {
      await Supabase.instance.client.from('chat_messages').update({
        'children': msg['children'],
        'current_child': msg['current_child'],
      }).eq('id', msg['id']);
    }
  }
}