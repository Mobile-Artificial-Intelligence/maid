part of 'package:maid/main.dart';

class ChatNode {
  final String id;
  final Chat chat;
  final String? parent;
  final List<String> children;
  String role;
  String content;

  ChatNode({
    required this.role,
    required this.content,
    required this.chat,
    this.parent,
    String? id,
    List<String>? children
  }) : id = id ?? _generateID(), 
      children = children ?? [];

  factory ChatNode.fromMap(Map<String, dynamic> map, Chat chat) {
    String role = map['role'] ?? map['message']['author']['role'];
    String content = map['content'] ?? (map['message']['content']['parts'] as List).cast<String>().join(' ');

    return ChatNode(
      chat: chat,
      parent: map['parent'],
      id: map['id'],
      children: (map['children'] as List).cast<String>(),
      role: role,
      content: content
    );
  }

  List<ChatNode> get history {
    final List<ChatNode> history = [];

    var current = this;
    while (current.parent != null) {
      history.add(current);
      current = chat.mappings[current.parent]!;
    }

    return history;
  }

  List<ChatNode> get siblings {
    if (parent == null) {
      return [];
    }

    final siblingKeys = chat.mappings[parent]!.children.where((element) => element != id).toList();

    return siblingKeys.map((key) => chat.mappings[key]!).toList();
  }

  void next() {
    if (parent == null) {
      return;
    }

    final index = chat.mappings[parent]!.children.indexOf(this.id);
    if (index == chat.mappings[parent]!.children.length - 1) {
      return;
    }

    chat._currentNode = chat.mappings[parent]!.children[index + 1];
  }

  void last() {
    if (parent == null) {
      return;
    }

    final index = chat.mappings[parent]!.children.indexOf(this.id);
    if (index == 0) {
      return;
    }

    chat._currentNode = chat.mappings[parent]!.children[index - 1];
  }

  void addChild(ChatNode node) {
    chat.addMapping(node);
    children.add(node.id);
  }
}