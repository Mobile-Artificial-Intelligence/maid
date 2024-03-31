import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maid/static/utilities.dart';

class ChatNode {
  final StreamController<String> messageController = StreamController<String>.broadcast();

  final Key key;
  final ChatRole role;

  String message;

  Key? currentChild;
  List<ChatNode> children;

  ChatNode({
    required this.key,
    required this.role,
    this.message = "",
    List<ChatNode>? children,
  }) : children = children ?? [];

  ChatNode.fromMap(Map<String, dynamic> map)
    : key = ValueKey(
      map['key'] as String? ?? Utilities.keyToString(UniqueKey())
    ),
    role = ChatRole.values[map['role'] as int? ?? ChatRole.system.index],
    message = map['message'] ?? "",
    currentChild = map['currentChild'] != null
        ? ValueKey(map['currentChild'] as String)
        : null,
    children = (map['children'] ?? [])
        .map((childMap) => ChatNode.fromMap(childMap))
        .toList()
        .cast<ChatNode>();

  Map<String, dynamic> toMap() {
    return {
      'key': Utilities.keyToString(key),
      'role': role.index,
      'message': message,
      'currentChild': currentChild != null ? Utilities.keyToString(currentChild!) : null,
      'children': children.map((child) => child.toMap()).toList(),
    };
  }
}

enum ChatRole {
  user,
  assistant,
  system
}