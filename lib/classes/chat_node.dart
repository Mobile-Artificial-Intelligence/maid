import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:maid/static/utilities.dart';

class ChatNode {
  final StreamController<String> messageController =
    StreamController<String>.broadcast();
  final StreamController<int> finaliseController =
    StreamController<int>.broadcast();

  final Key key;
  final bool userGenerated;

  String message;

  Key? currentChild;
  List<ChatNode> children;

  ChatNode({
    required this.key,
    this.message = "",
    List<ChatNode>? children,
    this.userGenerated = false,
  }) : children = children ?? [];

  ChatNode.fromMap(Map<String, dynamic> map)
      : key = ValueKey(map['key'] as String? ?? Utilities.keyToString(UniqueKey())),
        message = map['message'] ?? "",
        userGenerated = map['userGenerated'] ?? false,
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
      'message': message,
      'currentChild': currentChild != null
          ? Utilities.keyToString(currentChild!)
          : null,
      'userGenerated': userGenerated,
      'children': children.map((child) => child.toMap()).toList(),
    };
  }

  ChatNode? find(Key targetKey) {
    final Queue<ChatNode> queue = Queue.from([this]);

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();

      if (current.key == targetKey) {
        return current;
      }

      for (var child in current.children) {
        queue.add(child);
      }
    }

    return null;
  }

  ChatNode? getParent(Key targetKey) {
    final Queue<ChatNode> queue = Queue.from([this]);

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();

      for (var child in current.children) {
        if (child.key == targetKey) {
          return current;
        }
        queue.add(child);
      }
    }

    return null;
  }

  ChatNode findTail() {
    final Queue<ChatNode> queue = Queue.from([this]);

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();

      if (current.children.isEmpty || current.currentChild == null) {
        return current;
      } else {
        for (var child in current.children) {
          if (child.key == current.currentChild) {
            queue.add(child);
          }
        }
      }
    }

    return this;
  }
}