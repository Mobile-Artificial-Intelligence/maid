import 'dart:collection';
import 'chat_node.dart';

class ChatNodeTree {
  String buffer = "";

  ChatNode root = ChatNode(role: ChatRole.system, finalised: true);

  ChatNode get tail {
    final Queue<ChatNode> queue = Queue.from([root]);

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();

      if (current.children.isEmpty || current.currentChild == null) {
        return current;
      } 
      else {
        for (var child in current.children) {
          if (child.hash == current.currentChild) {
            queue.add(child);
          }
        }
      }
    }

    return root;
  }

  void add({
    String content = "",
    ChatRole role = ChatRole.user,
  }) {
    final node = ChatNode(content: content, role: role, finalised: content.isNotEmpty);
    tail.children.add(node);
    tail.currentChild = node.hash;
  }

  void addNode(ChatNode node) {
    var found = find(node.hash);
    if (found != null) {
      found.content = node.content;
    } 
    else {
      tail.children.add(node);
      tail.currentChild = node.hash;
    }
  }

  void remove(String hash) {
    var parent = parentOf(hash);
    if (parent != null) {
      parent.children.removeWhere((element) => element.hash == hash);
    }
  }

  void next(String hash) {
    var parent = parentOf(hash);
    if (parent != null) {
      if (parent.currentChild == null) {
        parent.currentChild = hash;
      } 
      else {
        var currentChildIndex = parent.children.indexWhere(
          (element) => element.hash == parent.currentChild
        );

        if (currentChildIndex < parent.children.length - 1) {
          parent.currentChild = parent.children[currentChildIndex + 1].hash;
        }
      }
    }
  }

  void last(String hash) {
    var parent = parentOf(hash);
    if (parent != null) {
      if (parent.currentChild == null) {
        parent.currentChild = hash;
      } 
      else {
        var currentChildIndex = parent.children.indexWhere(
          (element) => element.hash == parent.currentChild
        );

        if (currentChildIndex > 0) {
          parent.currentChild = parent.children[currentChildIndex - 1].hash;
        }
      }
    }
  }

  ChatNode? find(String hash) {
    final Queue<ChatNode> queue = Queue.from([root]);

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();

      if (current.hash == hash) {
        return current;
      }

      for (var child in current.children) {
        queue.add(child);
      }
    }

    return null;
  }

  ChatNode? parentOf(String hash) {
    final Queue<ChatNode> queue = Queue.from([root]);

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();

      for (var child in current.children) {
        if (child.hash == hash) {
          return current;
        }
        queue.add(child);
      }
    }

    return null;
  }

  String messageOf(String hash) {
    return find(hash)?.content ?? "";
  }

  int indexOf(String hash) {
    var parent = parentOf(hash);
    if (parent != null) {
      return parent.children.indexWhere((element) => element.hash == hash);
    } else {
      return 0;
    }
  }

  int siblingCountOf(String hash) {
    var parent = parentOf(hash);
    if (parent != null) {
      return parent.children.length;
    } else {
      return 0;
    }
  }

  List<ChatNode> getChat() {
    final List<ChatNode> chat = [];
    var current = root;

    while (current.currentChild != null) {
      current = find(current.currentChild!)!;
      if (current.content.isNotEmpty) {
        chat.add(current);
      }
    }

    return chat;
  }
}