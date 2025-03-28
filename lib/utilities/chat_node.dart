part of 'package:maid/main.dart';

abstract class ChatNode {
  String get role;
  final String id;
  final String? parent;
  final List<String> children;
  String content;

  ChatNode({
    required this.content,
    this.parent,
    String? id,
    List<String>? children
  }) : id = id ?? _generateID(), 
      children = children ?? [];

  factory ChatNode.fromMap(Map<String, dynamic> map, Chat chat) {
    String role = map['role'] ?? map['message']['author']['role'];
    String content = map['content'] ?? (map['message']['content']['parts'] as List).cast<String>().join(' ');

    switch (role) {
      case 'user':
        return UserChatNode(
          parent: map['parent'],
          id: map['id'],
          children: (map['children'] as List).cast<String>(),
          content: content
        );
      case 'assistant':
        return AssistantChatNode(
          parent: map['parent'],
          id: map['id'],
          children: (map['children'] as List).cast<String>(),
          content: content
        );
      case 'system':
        return SystemChatNode(
          parent: map['parent'],
          id: map['id'],
          children: (map['children'] as List).cast<String>(),
          content: content
        );
      default:
        throw Exception('Invalid role');
    }
  }

  List<ChatNode> get history {
    final List<ChatNode> history = [];

    var current = this;
    while (current.parent != null) {
      history.add(current);
      current = Chat.current.mappings[current.parent]!;
    }

    return history;
  }

  List<ChatNode> get siblings {
    if (parent == null) {
      return [];
    }

    final siblingKeys = Chat.current.mappings[parent]!.children.where((element) => element != id).toList();

    return siblingKeys.map((key) => Chat.current.mappings[key]!).toList();
  }

  void next() {
    if (parent == null) {
      return;
    }

    final index = Chat.current.mappings[parent]!.children.indexOf(id);
    if (index == Chat.current.mappings[parent]!.children.length - 1) {
      return;
    }

    Chat.current.currentNode = Chat.current.mappings[parent]!.children[index + 1];
  }

  void last() {
    if (parent == null) {
      return;
    }

    final index = Chat.current.mappings[parent]!.children.indexOf(id);
    if (index == 0) {
      return;
    }

    Chat.current.currentNode = Chat.current.mappings[parent]!.children[index - 1];
  }

  void addChild(ChatNode node) {
    Chat.current.addMapping(node);
    children.add(node.id);
  }
}

class UserChatNode extends ChatNode {
  UserChatNode({
    required super.content, 
    super.parent, 
    super.id, 
    super.children
  });

  @override
  String get role => 'user';
}

class AssistantChatNode extends ChatNode {
  AssistantChatNode({
    required super.content, 
    super.parent, 
    super.id, 
    super.children
  });

  @override
  String get role => 'assistant';
}

class SystemChatNode extends ChatNode {
  SystemChatNode({
    required super.content, 
    super.parent, 
    super.id, 
    super.children
  });

  @override
  String get role => 'system';
}