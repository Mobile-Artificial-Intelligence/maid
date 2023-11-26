import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maid/static/memory_manager.dart';
import 'package:maid/types/chat_node.dart';
import 'package:maid/static/generation_manager.dart';

class MessageManager {
  static TextEditingController promptController = TextEditingController();
  static FocusNode promptFocusNode = FocusNode();
  static void Function()? _callback;
  static ChatNode root = ChatNode(key: UniqueKey());
  static ChatNode? tail;
  static bool busy = false;

  static void registerCallback(void Function() onUpdate) {
    _callback = onUpdate;
  }

  static void deregisterCallback() {
    _callback = null;
  }

  static void fromMap(Map<String, dynamic> inputJson) {
    root = ChatNode.fromMap(inputJson);
    tail = root.findTail();
    _callback?.call();
  }

  static String get(Key key) {
    return root.find(key)?.message ?? "";
  }

  static void add(Key key, {String message = "",  bool userGenerated = false}) {
    final node = ChatNode(key: key, message: message, userGenerated: userGenerated);
    
    var found = root.find(key);
    if (found != null) {
      found.message = message;
    } else {
      tail ??= root.findTail();

      if (tail!.userGenerated == userGenerated) {
        stream(message);
        finalise();
      } else {
        tail!.children.add(node);
        tail!.currentChild = key;
        tail = tail!.findTail();
      }
    }

    _callback?.call();
  }

  static void remove(Key key) {
    var parent = root.getParent(key);
    if (parent != null) {
      parent.children.removeWhere((element) => element.key == key);
      tail = root.findTail();
    }
    GenerationManager.cleanup();
    _callback?.call();
  }

  static void stream(String message) async {     
    tail ??= root.findTail();
    if (!MessageManager.busy && !(tail!.userGenerated)) {
      finalise();
    } else {
      tail!.messageController.add(message);
    }
  }

  static void regenerate(Key key) { 
    var parent = root.getParent(key);
    if (parent == null) {
      return;
    } else {
      branch(key, false);
      MessageManager.busy = true;
      GenerationManager.prompt(parent.message);
    }
  }

  static void branch(Key key, bool userGenerated) {
    var parent = root.getParent(key);
    if (parent != null) {
      parent.currentChild = null;
      tail = root.findTail();
    }
    add(UniqueKey(), userGenerated: userGenerated);
    GenerationManager.cleanup();
    _callback?.call();
  }

  static void finalise() {
    tail ??= root.findTail();
    tail!.finaliseController.add(0);
    MemoryManager.saveSessions();
  }

  static void next(Key key) {
    var parent = root.getParent(key);
    if (parent != null) {
      if (parent.currentChild == null) {
        parent.currentChild = key;
      } else {
        var currentChildIndex = parent.children.indexWhere((element) => element.key == parent.currentChild);
        if (currentChildIndex < parent.children.length - 1) {
          parent.currentChild = parent.children[currentChildIndex + 1].key;
          tail = root.findTail();
        }
      }
    }

    GenerationManager.cleanup();
    _callback?.call();
  }

  static void last(Key key) {
    var parent = root.getParent(key);
    if (parent != null) {
      if (parent.currentChild == null) {
        parent.currentChild = key;
      } else {
        var currentChildIndex = parent.children.indexWhere((element) => element.key == parent.currentChild);
        if (currentChildIndex > 0) {
          parent.currentChild = parent.children[currentChildIndex - 1].key;
          tail = root.findTail();
        }
      }
    }

    GenerationManager.cleanup();
    _callback?.call();
  }

  static int siblingCount(Key key) {
    var parent = root.getParent(key);
    if (parent != null) {
      return parent.children.length;
    } else {
      return 0;
    }
  }

  static int index(Key key) {
    var parent = root.getParent(key);
    if (parent != null) {
      return parent.children.indexWhere((element) => element.key == key);
    } else {
      return 0;
    }
  }

  static Map<Key, bool> history() {
    final Map<Key, bool> history = {};
    var current = root;

    while (current.currentChild != null) {
      current = current.find(current.currentChild!)!;
      history[current.key] = current.userGenerated;
    }

    return history;
  }

  static List<Map<String, dynamic>> getMessages() {
    final List<Map<String, dynamic>> messages = [];
    var current = root;

    while (current.currentChild != null) {
      current = current.find(current.currentChild!)!;
      if (current.userGenerated) {
        messages.add({
          "prompt": current.message,
        });
      } else {
        messages.last["response"] = current.message;
      }
    }
    
    //remove last message if it is empty
    if (messages.last.isEmpty) {
      messages.remove(messages.last);
    }

    messages.remove(messages.last); //remove last message

    return messages;
  }

  static StreamController<String> getMessageStream(Key key) {
    return root.find(key)?.messageController ?? StreamController<String>.broadcast();
  }

  static StreamController<int> getFinaliseStream(Key key) {
    return root.find(key)?.finaliseController ?? StreamController<int>.broadcast();
  }
}