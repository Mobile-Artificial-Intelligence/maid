import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:maid/main.dart';

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
  }) : this.children = children ?? [];

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

class MessageManager {
  static ChatNode? root;
  static ChatNode? tail;

  static String get(Key key) {
    if (root == null) {
      return "";
    } else {
      return root!.find(key)?.message ?? "";
    }
  }

  static void add(Key key, {String message = "",  bool userGenerated = false}) {
    final node = ChatNode(key: key, message: message, userGenerated: userGenerated);
    if (root == null) {
      root = node;
      tail = node;
      homePageKey.currentState!.rebuildChat();
      print("root");
      return;
    } 
    
    var found = root!.find(key);
    if (found != null) {
      found.message = message;
      homePageKey.currentState!.rebuildChat();
      return;
    } else { 
      print("added");
      tail ??= root!.findTail();
      tail!.children.add(node);
      tail!.currentChild = key;
      tail = tail!.findTail();
    }
  }

  static void stream(String message) {
    if (root == null) {
      return;
    }
    tail ??= root!.findTail();
    tail!.messageController.add(message);
    homePageKey.currentState!.rebuildChat();
  }

  static void split(Key key) {
    if (root == null) {
      return;
    } else {
      var parent = root!.getParent(key);
      if (parent != null) {
        parent.currentChild = null;
        tail = root!.findTail();
      }
    }
    homePageKey.currentState!.rebuildChat();
  }

  static void finalise() {
    if (root == null) {
      return;
    } else {
      tail ??= root!.findTail();
      tail!.finaliseController.add(0);
    }
  }

  static void nextChild(Key key) {
    if (root == null) {
      return;
    } else {
      var parent = root!.find(key);
      if (parent != null) {
        if (parent.currentChild == null) {
          parent.currentChild = parent.children.first.key;
        } else {
          var currentChildIndex = parent.children.indexWhere((element) => element.key == parent.currentChild);
          if (currentChildIndex < parent.children.length - 1) {
            parent.currentChild = parent.children[currentChildIndex + 1].key;
            tail = root!.findTail();
          }
        }
      }
    }
    homePageKey.currentState!.rebuildChat();
  }

  static void lastChild(Key key) {
    if (root == null) {
      return;
    } else {
      var parent = root!.find(key);
      if (parent != null) {
        if (parent.currentChild == null) {
          parent.currentChild = parent.children.last.key;
        } else {
          var currentChildIndex = parent.children.indexWhere((element) => element.key == parent.currentChild);
          if (currentChildIndex > 0) {
            parent.currentChild = parent.children[currentChildIndex - 1].key;
            tail = root!.findTail();
          }
        }
      }
    }
    homePageKey.currentState!.rebuildChat();
  }

  static List<ChatNode> getHistory() {
    if (root == null) {
      return [];
    } else {
      final List<ChatNode> history = [];
      var current = root!;

      history.add(current);
      while (current.currentChild != null) {
        current = current.find(current.currentChild!)!;
        history.add(current);
      }

      return history;
    }
  }

  static StreamController<String> getMessageStream(Key key) {
    if (root == null) {
      return StreamController<String>.broadcast();
    } else {
      return root!.find(key)?.messageController ?? StreamController<String>.broadcast();
    }
  }

  static StreamController<int> getFinaliseStream(Key key) {
    if (root == null) {
      return StreamController<int>.broadcast();
    } else {
      return root!.find(key)?.finaliseController ?? StreamController<int>.broadcast();
    }
  }
}