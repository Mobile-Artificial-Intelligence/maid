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
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ChatMessage>? children,
    ChatMessage? currentChild,
  })  : id = id ?? ValueKey<String>(math.Random().nextInt(2^62).toString().hash),
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
    
    for (final child in _children) {
      child.parent = this;
    }
  }

  ChatMessage.withStream({
    ValueKey<String>? id,
    required this.role,
    required Stream<String> stream,
    DateTime? createdAt,
    List<ChatMessage>? children,
    ChatMessage? currentChild,
  }) : id = id ?? ValueKey<String>(math.Random().nextInt(2^62).toString().hash),
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

    for (final child in _children) {
      child.parent = this;
    }

    listenToStream(stream);
  }

  factory ChatMessage.fromMapList(List<Map<String, dynamic>> mapList, [ValueKey<String>? id]) {
    id ??= ValueKey<String>(mapList.firstWhere(
      (map) => map['parent'] == null,
      orElse: () => throw ArgumentError('No root found in mapList'),
    )['id']);

    final map = mapList.firstWhere(
      (map) => map['id'] == id!.value,
      orElse: () => throw ArgumentError('No message found with id: ${id!.value}'),
    );

    List<ChatMessage> children = [];
    for (final childId in map['children']) {
      children.add(ChatMessage.fromMapList(mapList, ValueKey<String>(childId)));
    }

    ChatMessage? currentChild;
    if (map['current_child'] != null) {
      currentChild = children.firstWhere(
        (child) => child.id.value == map['current_child'],
        orElse: () => throw ArgumentError('No child found with id: ${map['current_child']}'),
      );
    }

    DateTime? createdAt;
    if (map['create_time'] is String) {
      createdAt = DateTime.parse(map['create_time']);
    }
    else if (map['create_time'] is double) {
      createdAt = DateTime.fromMillisecondsSinceEpoch((map['create_time'] * 1000 as double).toInt());
    }

    DateTime? updatedAt;
    if (map['update_time'] is String) {
      updatedAt = DateTime.parse(map['update_time']);
    }
    else if (map['update_time'] is double) {
      updatedAt = DateTime.fromMillisecondsSinceEpoch((map['update_time'] * 1000 as double).toInt());
    }

    return ChatMessage(
      id: id,
      role: ChatMessageRole.fromString(map['role']),
      content: map['content'],
      createdAt: createdAt,
      updatedAt: updatedAt,
      children: children,
      currentChild: currentChild,
    );
  }

  final List<ChatMessage> _children;

  List<ChatMessage> get children => _children;

  ChatMessage? _parent;

  ChatMessage? get parent => _parent;

  set parent(ChatMessage? value) {
    if (_parent != null) {
      throw ArgumentError('Parent already set');
    }

    _parent = value;
    notifyListeners();
  }

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

  void addChild(ChatMessage child) {
    _children.add(child);
    child.parent = this;
    _currentChild = child;
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
      'children': children.map((child) => child.id.value).toList(),
      'current_child': currentChild?.id.value,
      'role': role.name,
      'content': content,
      'create_time': createdAt.toIso8601String(),
      'update_time': updatedAt.toIso8601String(),
    }];

    for (final child in _children) {
      mapList.addAll(child.toMapList());
    }

    return mapList;
  }
}