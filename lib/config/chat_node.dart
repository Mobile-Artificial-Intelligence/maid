import 'dart:collection';

import 'package:flutter/material.dart';

ChatNode? rootNode;

class ChatNode {
  final Key key;
  final String message;
  final bool userGenerated;

  Key? currentChild;
  List<ChatNode> children;

  ChatNode({
    required this.key,
    required this.message,
    List<ChatNode>? children,
    this.userGenerated = false,
  }) : this.children = children ?? [];

  ChatNode? _find(Key targetKey) {
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

  ChatNode? _findTail() {
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

    return null;
  }

  List<ChatNode>? getPath(Key targetKey) {
    final Map<ChatNode, ChatNode?> parents = {};  // ChatNode? for values
    final Queue<ChatNode> queue = Queue.from([this]);

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();

      if (current.key == targetKey) {
        final path = <ChatNode>[];

        var nodeInPath = current;
        while (true) {
          path.insert(0, nodeInPath);
          final parentNode = parents[nodeInPath];
          if (parentNode != null) {
            nodeInPath = parentNode;
          } else {
            break;
          }
        }

        return path;
      }

      for (var child in current.children) {
        parents[child] = current;
        queue.add(child);
      }
    }

    return null;
  }


  ChatNode? _getParent(Key targetKey) {
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

  static String getChat(Key key) {
    if (rootNode == null) {
      return "";
    } else {
      return rootNode!._find(key)?.message ?? "";
    }
  }

  static void insertChat(Key key, String message, bool userGenerated) {
    if (rootNode == null) {
      rootNode = ChatNode(key: key, message: message, userGenerated: userGenerated);
    } else {
      var parent = rootNode!._findTail();
      if (parent != null) {
        parent.children.add(ChatNode(key: key, message: message, userGenerated: userGenerated));
      }
    }
  }

  static void split(Key key) {
    if (rootNode == null) {
      return;
    } else {
      var parent = rootNode!._getParent(key);
      if (parent != null) {
        parent.currentChild = null;
      }
    }
  }

  static void nextChild(Key key) {
    if (rootNode == null) {
      return;
    } else {
      var parent = rootNode!._find(key);
      if (parent != null) {
        if (parent.currentChild == null) {
          parent.currentChild = parent.children.first.key;
        } else {
          var currentChildIndex = parent.children.indexWhere((element) => element.key == parent.currentChild);
          if (currentChildIndex < parent.children.length - 1) {
            parent.currentChild = parent.children[currentChildIndex + 1].key;
          }
        }
      }
    }
  }

  static void lastChild(Key key) {
    if (rootNode == null) {
      return;
    } else {
      var parent = rootNode!._find(key);
      if (parent != null) {
        if (parent.currentChild == null) {
          parent.currentChild = parent.children.last.key;
        } else {
          var currentChildIndex = parent.children.indexWhere((element) => element.key == parent.currentChild);
          if (currentChildIndex > 0) {
            parent.currentChild = parent.children[currentChildIndex - 1].key;
          }
        }
      }
    }
  }
}