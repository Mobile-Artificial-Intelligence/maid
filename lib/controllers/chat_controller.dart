part of 'package:maid/main.dart';

class ChatController extends ChangeNotifier {
  ChatController({
    List<GeneralTreeNode<ChatMessage>>? chats,
  }) : _chats = chats ?? [];

  ChatController.load() {
    load();
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

    save();
    notifyListeners();
  }

  void newChat() {
    final chat = GeneralTreeNode<ChatMessage>(SystemChatMessage('New Chat'));

    _chats.insert(0, chat);
    
    save();
    notifyListeners();
  }

  void deleteChat(GeneralTreeNode<ChatMessage> chat) {
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
      final chat = GeneralTreeNode.fromMap(chatMap, ChatMessage.fromMap);

      _chats.insert(0, chat);
      save();
      notifyListeners();
    }
  }

  void exportChat(GeneralTreeNode<ChatMessage> chat) async {
    final chatMap = chat.toMap(ChatMessage.messageToMap);
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

  void addToEnd(ChatMessage message) {
    root.chain.last.addChild(message);
    save();
    notifyListeners();
  }

  Future<void> streamToEnd(Stream<String> stream) async {
    root.chain.last.addChild(AssistantChatMessage(''));
    notifyListeners();

    await for (final response in stream) {
      root.chain.last.data.content += response;
      notifyListeners();
    }

    save();
    notifyListeners();
  }

  Future<void> streamToChild(GeneralTreeNode<ChatMessage> node, Stream<String> stream) async {
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

String _generateID() {
  final codeUnits = List<int>.generate(10, (index) {
    return  math.Random().nextInt(33) + 89;
  });

  return String.fromCharCodes(codeUnits);
}

class _ChatController extends ChangeNotifier{
  final String id;

  String _title;

  String get title => _title;

  set title(String title) {
    _title = title;
    _updatedAt = DateTime.now();
  }

  final DateTime _createdAt;

  DateTime get createdAt => _createdAt;

  DateTime _updatedAt;

  DateTime get updatedAt => _updatedAt;

  Map<String, dynamic> _properties;

  Map<String, dynamic> get properties => _properties;

  set properties(Map<String, dynamic> properties) {
    _properties = properties;
    _updatedAt = DateTime.now();
  }

  final Map<String, ChatNode> _mappings;

  void addMapping(ChatNode node) {
    _mappings[node.id] = node;
    _updatedAt = DateTime.now();
  }

  _ChatController({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? currentNode,
    Map<String, ChatNode>? mappings,
    Map<String, dynamic>? properties,
  }) : id = id ?? _generateID(),
       _title = title ?? '',
       _createdAt = createdAt ?? DateTime.now(),
       _updatedAt = updatedAt ?? DateTime.now(),
       _mappings = mappings ?? {},
       _properties = properties ?? {};

  factory _ChatController.fromMap(Map<String, dynamic> map) {
    final String id = map['id'];
    map.remove('id');

    final String title = map['title'];
    map.remove('title');

    final DateTime createdAt = DateTime.parse((map['create_time'] as num).toInt().toString());
    map.remove('create_time');

    final DateTime updatedAt = DateTime.parse((map['update_time'] as num).toInt().toString());
    map.remove('update_time');

    final String? currentNode = map['current_node'];
    map.remove('current_node');
    
    final Map<String, dynamic> mappings = map['mapping'];
    map.remove('mapping');
    
    final tree = _ChatController(
      id: id,
      title: title,
      createdAt: createdAt,
      updatedAt: updatedAt,
      currentNode: currentNode,
      properties: map,
    );

    for (final mapping in mappings.values) {
      final node = GeneralTreeNode<T>.fromMap(
        map: mapping,
        tree: tree,
        typeBuilder: typeBuilder,
      );
      
      tree.addMapping(node);
    }

    return tree;
  }

  List<ChatNode> get chain {
    
  }
}

class ChatNode {
  final String id;
  final String role;
  final String content;
  final ChatNode? parent;
  final List<ChatNode> children = [];
  ChatNode? _currentChild;

  ChatNode? get currentChild => _currentChild;

  ChatNode({
    required this.role,
    required this.content,
    this.parent,
    String? id
  }) : id = id ?? _generateID();

  factory ChatNode.fromMap(Map<String, dynamic> map, String id, [ChatNode? parent]) {
    final Map<String, dynamic> entry = map[id];
    assert(id == entry['id'], "ID mismatch: $id != ${entry['id']}");

    final String role = entry['role'] ?? entry['message']['author']['role'];
    final String content = entry['content'] ?? entry['message']['content']['parts'][0];

    final node = ChatNode(
      id: id,
      role: role,
      content: content,
      parent: parent
    );

    final List<ChatNode> children = (entry['children'] as List).map((child) => ChatNode.fromMap(map, child, node)).toList();
    node.children.addAll(children);

    return node;
  }

  List<ChatNode> get history {
    final List<ChatNode> history = [];

    var current = this;
    while (current.parent != null) {
      history.add(current);
      current = current.parent!;
    }

    return history;
  }

  List<ChatNode> get siblings {
    if (parent == null) {
      return [];
    }

    return parent!.children.where((element) => element.id != id).toList();
  }

  void next(ChatController controller) {
    if (parent == null) {
      return;
    }

    final index = parent!.children.indexOf(this);
    if (index == parent!.children.length - 1) {
      return;
    }

    _currentChild = parent!.children[index + 1];
  }

  void last() {
    if (parent == null) {
      return;
    }

    final index = parent!.children.indexOf(this);
    if (index == 0) {
      return;
    }

    _currentChild = parent!.children[index - 1];
  }
}

extension Mappings on Map<String, ChatNode> {
  static Map<String, ChatNode> fromMap(Map<String, dynamic> map) {
    final Map<String, ChatNode> mappings = {};

    // Find the entry where the parent is null, there must be one and only one
    final roots = map.entries.where((entry) => entry.value['parent'] == null);

    // Assert that there is only one root entry
    assert(roots.length == 1, "There must be one and only one root entry");

    final ChatNode root = ChatNode.fromMap(map, roots.first.key);

    return mappings;
  }
}