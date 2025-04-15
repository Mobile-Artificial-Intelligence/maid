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
      case 'system':
        return system;
      default:
        throw ArgumentError('Invalid role: $role');
    }
  }
}

class ChatMessage extends ChangeNotifier {
  ChatMessage({
    ValueKey<String>? id,
    required this.role,
    required String content,
    required this.parent,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? ValueKey<String>(math.Random().nextInt(2^62).toString().hash),
        _updatedAt = updatedAt ?? DateTime.now(),
        _content = content,
        createdAt = createdAt ?? DateTime.now() {
    if (parent != null) {
      parent!._children.add(this);
      parent!._currentChild = this;
    }
  }

  ChatMessage.withStream({
    ValueKey<String>? id,
    required this.role,
    required Stream<String> stream,
    required this.parent,
    DateTime? createdAt,
  }) : id = id ?? ValueKey<String>(math.Random().nextInt(2^62).toString().hash),
        _updatedAt = DateTime.now(),
        _content = '',
        createdAt = createdAt ?? DateTime.now() {
    if (parent != null) {
      parent!._children.add(this);
      parent!._currentChild = this;
    }

    listenToStream(stream);
  }

  factory ChatMessage.fromMapList(List<Map<String, dynamic>> mapList, {ValueKey<String>? id, ChatMessage? parent}) {
    id ??= ValueKey<String>(mapList.firstWhere(
      (map) => map['parent'] == null,
      orElse: () => throw ArgumentError('No root found in mapList'),
    )['id']);

    final map = mapList.firstWhere(
      (map) => map['id'] == id!.value,
      orElse: () => throw ArgumentError('No message found with id: ${id!.value}'),
    );

    final result = ChatMessage(
      id: id,
      parent: parent,
      role: ChatMessageRole.fromString(map['role']),
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );

    for (final childId in map['children']) {
      ChatMessage.fromMapList(mapList, id: ValueKey<String>(childId), parent: result);
    }

    if (map['current_child'] != null) {
      result._currentChild = result._children.firstWhere(
        (child) => child.id.value == map['current_child'],
        orElse: () => throw ArgumentError('No child found with id: ${map['current_child']}'),
      );
    }

    return result;
  }

  final List<ChatMessage> _children = [];

  List<ChatMessage> get children => _children;

  final ValueKey<String> id;
  final ChatMessage? parent;
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

  ChatMessage? _currentChild;

  ChatMessage? get currentChild => _currentChild;

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

  void removeChild(ChatMessage child) {
    _children.remove(child);
    _currentChild = _children.isNotEmpty ? _children.first : null;
    _updatedAt = DateTime.now();
    notifyListeners();
  }

  ChatMessage get tail {
    if (_children.isEmpty) return this;

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

  List<Map<String, dynamic>> toMapList() {
    final mapList = [{
      'id': id.value,
      'parent': parent?.id.value,
      'children': _children.map((child) => child.id.value).toList(),
      'current_child': _currentChild?.id.value,
      'role': role.name,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    }];

    for (final child in _children) {
      mapList.addAll(child.toMapList());
    }

    return mapList;
  }
}