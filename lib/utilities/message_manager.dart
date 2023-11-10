import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:maid/utilities/generation_manager.dart';
import 'package:maid/utilities/model.dart';
import 'package:maid/core/local_generation.dart';

class MessageManager {
  static void Function()? _callback;
  static final _ChatNode _root = _ChatNode(key: UniqueKey());
  static _ChatNode? _tail;
  static bool busy = false;

  static void registerCallback(void Function() onUpdate) {
    _callback = onUpdate;
  }

  static String get(Key key) {
    return _root.find(key)?.message ?? "";
  }

  static void add(Key key, {String message = "",  bool userGenerated = false}) {
    final node = _ChatNode(key: key, message: message, userGenerated: userGenerated);
    
    var found = _root.find(key);
    if (found != null) {
      found.message = message;
    } else {
      _tail ??= _root.findTail();

      if (_tail!.userGenerated == userGenerated) {
        stream(message);
        finalise();
      } else {
        _tail!.children.add(node);
        _tail!.currentChild = key;
        _tail = _tail!.findTail();
      }
    }

    _callback?.call();
  }

  static void remove(Key key) {
    var parent = _root.getParent(key);
    if (parent != null) {
      parent.children.removeWhere((element) => element.key == key);
      _tail = _root.findTail();
    }
    LocalGeneration.instance.cleanup();
    _callback?.call();
  }

  static void stream(String message) async {     
    _tail ??= _root.findTail();
    if (!model.busy && !(_tail!.userGenerated)) {
      busy = false;
      finalise();
    } else {
      _tail!.messageController.add(message);
    }
  }

  static void regenerate(Key key) { 
    var parent = _root.getParent(key);
    if (parent == null) {
      return;
    } else {
      branch(key, false);
      model.busy = true;
      GenerationManager.prompt(parent.message);
    }
  }

  static void branch(Key key, bool userGenerated) {
    var parent = _root.getParent(key);
    if (parent != null) {
      parent.currentChild = null;
      _tail = _root.findTail();
    }
    add(UniqueKey(), userGenerated: userGenerated);
    LocalGeneration.instance.cleanup();
    _callback?.call();
  }

  static void finalise() {
    _tail ??= _root.findTail();
    _tail!.finaliseController.add(0);
  }

  static void next(Key key) {
    var parent = _root.getParent(key);
    if (parent != null) {
      if (parent.currentChild == null) {
        parent.currentChild = key;
      } else {
        var currentChildIndex = parent.children.indexWhere((element) => element.key == parent.currentChild);
        if (currentChildIndex < parent.children.length - 1) {
          parent.currentChild = parent.children[currentChildIndex + 1].key;
          _tail = _root.findTail();
        }
      }
    }

    LocalGeneration.instance.cleanup();
    _callback?.call();
  }

  static void last(Key key) {
    var parent = _root.getParent(key);
    if (parent != null) {
      if (parent.currentChild == null) {
        parent.currentChild = key;
      } else {
        var currentChildIndex = parent.children.indexWhere((element) => element.key == parent.currentChild);
        if (currentChildIndex > 0) {
          parent.currentChild = parent.children[currentChildIndex - 1].key;
          _tail = _root.findTail();
        }
      }
    }

    LocalGeneration.instance.cleanup();
    _callback?.call();
  }

  static int siblingCount(Key key) {
    var parent = _root.getParent(key);
    if (parent != null) {
      return parent.children.length;
    } else {
      return 0;
    }
  }

  static int index(Key key) {
    var parent = _root.getParent(key);
    if (parent != null) {
      return parent.children.indexWhere((element) => element.key == key);
    } else {
      return 0;
    }
  }

  static Map<Key, bool> history() {
    final Map<Key, bool> history = {};
    var current = _root;

    while (current.currentChild != null) {
      current = current.find(current.currentChild!)!;
      history[current.key] = current.userGenerated;
    }

    return history;
  }

  static Map<String, bool> getMessages() {
    final Map<String, bool> messages = {};
    var current = _root;

    while (current.currentChild != null) {
      current = current.find(current.currentChild!)!;
      messages[current.message] = current.userGenerated;
    }
    
    //remove last message if it is empty
    if (messages.keys.last.isEmpty) {
      messages.remove(messages.keys.last);
    }

    messages.remove(messages.keys.last); //remove last message

    return messages;
  }

  static StreamController<String> getMessageStream(Key key) {
    return _root.find(key)?.messageController ?? StreamController<String>.broadcast();
  }

  static StreamController<int> getFinaliseStream(Key key) {
    return _root.find(key)?.finaliseController ?? StreamController<int>.broadcast();
  }
}

class _ChatNode {
  final StreamController<String> messageController =
    StreamController<String>.broadcast();
  final StreamController<int> finaliseController =
    StreamController<int>.broadcast();

  final Key key;
  final bool userGenerated;

  String message;

  Key? currentChild;
  List<_ChatNode> children;

  _ChatNode({
    required this.key,
    this.message = "",
    List<_ChatNode>? children,
    this.userGenerated = false,
  }) : children = children ?? [];

  _ChatNode? find(Key targetKey) {
    final Queue<_ChatNode> queue = Queue.from([this]);

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

  _ChatNode? getParent(Key targetKey) {
    final Queue<_ChatNode> queue = Queue.from([this]);

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

  _ChatNode findTail() {
    final Queue<_ChatNode> queue = Queue.from([this]);

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