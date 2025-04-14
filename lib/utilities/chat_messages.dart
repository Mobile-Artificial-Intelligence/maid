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
        createdAt = createdAt ?? DateTime.now();

  factory ChatMessage.fromMapList(List<Map<String, dynamic>> mapList, ValueKey<String>? id, [ChatMessage? parent]) {
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
      final child = ChatMessage.fromMapList(mapList, ValueKey<String>(childId), result);
      result.addChild(child, false);
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

  void addChild(ChatMessage child, [bool notify = true]) {
    _children.add(child);
    _currentChild = child;
    
    if (notify) {
      _updatedAt = DateTime.now();
      notifyListeners();
    }
  }

  void removeChild(ChatMessage child) {
    _children.remove(child);
    _currentChild = null;
    _updatedAt = DateTime.now();
    notifyListeners();
  }

  List<Map<String, dynamic>> toMapList() {
    final mapList = [{
      'id': id.value,
      'parent': parent?.id.value,
      'children': _children.map((child) => child.id).toList(),
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