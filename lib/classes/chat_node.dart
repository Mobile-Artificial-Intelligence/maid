import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:maid_llm/maid_llm.dart';

class ChatNode {
  late String hash;
  late ChatRole role;

  String content = '';
  bool finalised = false;

  String? currentChild;
  List<ChatNode> children = [];

  ChatNode({
    required this.role,
    this.content = "",
    this.finalised = false,
    List<ChatNode>? children,
  }) : 
  hash = _generateRandomHash(),
  children = children ?? [];

  ChatNode.fromMap(Map<String, dynamic> map) {
    hash = map['hash'] ?? _generateRandomHash();
    role = ChatRole.values[map['role']];
    content = map['content'];
    finalised = true;
    currentChild = map['currentChild'];
    children = (map['children'] as List).map((child) => ChatNode.fromMap(child)).toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'hash': hash,
      'role': role.index,
      'content': content,
      'currentChild': currentChild,
      'children': children.map((child) => child.toMap()).toList(),
    };
  }

  ChatMessage toChatMessage() {
    return ChatMessage(role: role.name, content: content);
  }

  static String _generateRandomHash() {
    var random = Random.secure();
    var values = List<int>.generate(32, (i) => random.nextInt(256));
    return sha256.convert(values).toString();
  }
}

enum ChatRole {
  system,
  user,
  assistant
}