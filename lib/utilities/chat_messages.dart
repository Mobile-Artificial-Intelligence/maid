part of 'package:maid/main.dart';

enum ChatMessageRole {
  user,
  assistant,
  system;

  static ChatMessageRole fromString(String role) {
    switch (role) {
      case 'user':
        return user;
      case 'assistant':
        return assistant;
      default:
        return system;
    }
  }
}

class ChatMessage extends ChangeNotifier {
  ChatMessage({
    ValueKey<String>? id,
    ValueKey<String>? parent,
    required this.role,
    required String content,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ValueKey<String>>? children,
    ValueKey<String>? currentChild,
  })  : id = id ?? ValueKey<String>(const Uuid().v7()),
        _parent = parent,
        _updatedAt = updatedAt ?? DateTime.now(),
        _content = content,
        createdAt = createdAt ?? DateTime.now(),
        _children = children ?? [],
        _currentChild = currentChild {
    if (currentChild == null) {
      _currentChild = _children.isNotEmpty ? _children.first : null;
    }
    else if (!_children.contains(currentChild)) {
      _children.add(currentChild);
    }
  }

  ChatMessage.withStream({
    ValueKey<String>? id,
    ValueKey<String>? parent,
    required this.role,
    required Stream<String> stream,
    DateTime? createdAt,
    List<ValueKey<String>>? children,
    ValueKey<String>? currentChild,
  }) : id = id ?? ValueKey<String>(const Uuid().v7()),
       _parent = parent,
       _updatedAt = DateTime.now(),
       _content = '',
       createdAt = createdAt ?? DateTime.now(),
       _children = children ?? [],
       _currentChild = currentChild {
    if (currentChild == null) {
      _currentChild = _children.isNotEmpty ? _children.first : null;
    }
    else if (!_children.contains(currentChild)) {
      _children.add(currentChild);
    }

    listenToStream(stream);
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    final id = ValueKey<String>(map['id'] as String);
    final parent = map['parent'] != null ? ValueKey<String>(map['parent'] as String) : null;
    final role = ChatMessageRole.fromString(map['role'] as String);
    final content = map['content'] as String;
    final createdAt = map['create_time'] != null ? DateTime.parse(map['create_time'] as String) : null;
    final updatedAt = map['update_time'] != null ? DateTime.parse(map['update_time'] as String) : null;
    final children = map['children'] != null && map['children'] is List ? (map['children'] as List).map((e) => ValueKey<String>(e as String)).toList() : <ValueKey<String>>[];
    final currentChild = map['current_child'] != null ? ValueKey<String>(map['current_child'] as String) : null;

    return ChatMessage(
      id: id,
      parent: parent,
      role: role,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
      children: children,
      currentChild: currentChild,
    );
  }

  final List<ValueKey<String>> _children;

  List<ChatMessage> get children => _children.map((key) => ChatController.instance.mapping[key]!).toList();

  final ValueKey<String>? _parent;

  bool get isRoot => _parent == null;

  ChatMessage? get parent => _parent != null ? ChatController.instance.mapping[_parent] : null;

  final ValueKey<String> id;
  final ChatMessageRole role;
  final DateTime createdAt;

  DateTime _updatedAt;

  DateTime get updatedAt => _updatedAt;

  String _content;

  String get content => _content;

  set content(String value) {
    _content = value;
    _updatedAt = DateTime.now();
    notifyListeners();
  }

  Future<void> listenToStream(Stream<String> stream) async {
    await for (final event in stream) {
      content += event;
    }
  }

  ValueKey<String>? _currentChild;

  ChatMessage? get currentChild => _currentChild != null ? ChatController.instance.mapping[_currentChild!] : null;

  void nextChild() {
    if (_children.isEmpty) return;

    int index = 0;
    if (_currentChild != null) {
      final lastIndex = _children.indexOf(_currentChild!);
      index = math.min(_children.length - 1, lastIndex + 1);
    }
    _currentChild = _children[index];

    _updatedAt = DateTime.now();
    notifyListeners();
  }

  void previousChild() {
    if (_children.isEmpty) return;

    int index = 0;
    if (_currentChild != null) {
      final lastIndex = _children.indexOf(_currentChild!);
      index = math.max(0, lastIndex - 1);
    }
    _currentChild = _children[index];

    _updatedAt = DateTime.now();
    notifyListeners();
  }

  void addChild(ChatMessage child) {
    ChatController.instance.addMessage(child);
    _children.add(child.id);
    _currentChild = child.id;
    _updatedAt = DateTime.now();
    notifyListeners();
  }

  void removeChild(ChatMessage child) {
    ChatController.instance.deleteMessage(child);
    _children.remove(child.id);
    _currentChild = _children.isNotEmpty ? _children.first : null;
    _updatedAt = DateTime.now();
    notifyListeners();
  }

  ChatMessage get root {
    if (parent == null) return this;

    ChatMessage root = this;
    do {
      if (root.parent != null) {
        root = root.parent!;
      }
    } while (root.parent != null);

    return root;
  }

  ChatMessage get tail {
    if (children.isEmpty) return this;

    ChatMessage tail = this;
    do {
      if (tail.currentChild != null) {
        tail = tail.currentChild!;
      }
    } while (tail.currentChild != null);

    return tail;
  }

  List<ChatMessage> get chain {
    final List<ChatMessage> chain = [];

    ChatMessage current = this;
    do {
      chain.add(current);
      
      if (current.currentChild != null) {
        current = current.currentChild!;
      }
    } while (current.currentChild != null);

    return chain;
  }

  List<ChatMessage> get chainReverse {
    final List<ChatMessage> chain = [];

    ChatMessage current = this;
    do {
      chain.add(current);

      if (current.parent != null) {
        current = current.parent!;
      }
    } while (current.parent != null);

    return chain;
  }

  int get currentChildIndex => _children.indexOf(_currentChild!);

  Map<String, dynamic> toMap() => {
    'id': id.value,
    'parent': _parent?.value,
    'children': _children.map((child) => child.value).toList(),
    'current_child': _currentChild?.value,
    'role': role.name,
    'content': content,
    'create_time': createdAt.toIso8601String(),
    'update_time': updatedAt.toIso8601String(),
  };
}