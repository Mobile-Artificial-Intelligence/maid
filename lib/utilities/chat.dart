part of 'package:maid/main.dart';

String _generateID([int length = 32]) {
  final random = math.Random.secure();
  final values = List<int>.generate(length, (i) => random.nextInt(256));
  return sha256.convert(values).toString();
}

class Chat {
  static List<Chat> instances = [];

  static Chat get current => instances.first;

  final String id;

  String _title;

  String get title => _title;

  set title(String title) {
    _title = title;
    _updatedAt = DateTime.now();
  }

  final DateTime _createdAt;

  DateTime get createdAt => _createdAt;

  DateTime _updatedAt;

  DateTime get updatedAt => _updatedAt;

  String? _currentNode;

  String? get currentNode {
    if (_currentNode == null && mappings.isNotEmpty) {
      _currentNode = mappings.values.first.id;
      _updatedAt = DateTime.now();
    }

    return _currentNode;
  }

  set currentNode(String? currentNode) {
    _currentNode = currentNode;
    _updatedAt = DateTime.now();
  }

  Map<String, dynamic> _properties;

  Map<String, dynamic> get properties => _properties;

  set properties(Map<String, dynamic> properties) {
    _properties = properties;
    _updatedAt = DateTime.now();
  }

  final Map<String, ChatNode> mappings = {};

  void addMapping(ChatNode node) {
    mappings[node.id] = node;
    _updatedAt = DateTime.now();
  }

  Chat({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? currentNode,
    Map<String, dynamic>? properties,
  }) : id = id ?? _generateID(),
       _title = title ?? 'New Chat',
       _createdAt = createdAt ?? DateTime.now(),
       _updatedAt = updatedAt ?? DateTime.now(),
       _currentNode = currentNode,
       _properties = properties ?? {} {
        instances.insert(0, this);
       }

  factory Chat.fromMap(Map<String, dynamic> map) {
    final String id = map['id'];
    map.remove('id');

    final String title = map['title'];
    map.remove('title');

    final DateTime createdAt = DateTime.parse((map['create_time'] as num).toInt().toString());
    map.remove('create_time');

    final DateTime updatedAt = DateTime.parse((map['update_time'] as num).toInt().toString());
    map.remove('update_time');

    final String? currentNode = map['current_node'];
    map.remove('current_node');
    
    final Map<String, dynamic> mappings = map['mapping'];
    map.remove('mapping');
    
    final tree = Chat(
      id: id,
      title: title,
      createdAt: createdAt,
      updatedAt: updatedAt,
      currentNode: currentNode,
      properties: map,
    );

    for (final mapping in mappings.values) {
      final node = ChatNode.fromMap(mapping, tree);
    
      tree.addMapping(node);
    }

    return tree;
  }

  List<ChatNode> get chain {
    if (currentNode == null) {
      return [];
    }

    return mappings[currentNode]!.history.reversed.toList();
  }

  List<ollama.Message> toOllamaMessages() {
    final List<ollama.Message> messages = [];

    for (final chatNode in chain) {
      ollama.MessageRole role;
      if (chatNode is UserChatNode) {
        role = ollama.MessageRole.user;
      } else if (chatNode is AssistantChatNode) {
        role = ollama.MessageRole.assistant;
      } else {
        role = ollama.MessageRole.system;
      }

      final ollama.Message message = ollama.Message(
        role: role,
        content: chatNode.content,
      );

      messages.add(message);
    }

    return messages;
  }

  List<open_ai.ChatCompletionMessage> toOpenAiMessages() {
    final List<open_ai.ChatCompletionMessage> messages = [];

    for (final chatNode in chain) {
      if (chatNode is UserChatNode) {
        final content = open_ai.ChatCompletionUserMessageContent.string(chatNode.content);

        final message = open_ai.ChatCompletionMessage.user(content: content);

        messages.add(message);
      }
      else if (chatNode is AssistantChatNode) {
        final message = open_ai.ChatCompletionMessage.assistant(content: chatNode.content);

        messages.add(message);
      }
      else {
        final message = open_ai.ChatCompletionMessage.system(content: chatNode.content);

        messages.add(message);
      }
    }

    return messages;
  }

  List<mistral.ChatCompletionMessage> toMistralMessages() {
    final List<mistral.ChatCompletionMessage> messages = [];

    for (final chatNode in chain) {
      mistral.ChatCompletionMessageRole role;

      if (chatNode is UserChatNode) {
        role = mistral.ChatCompletionMessageRole.user;
      } else if (chatNode is AssistantChatNode) {
        role = mistral.ChatCompletionMessageRole.assistant;
      } else {
        role = mistral.ChatCompletionMessageRole.system;
      }

      final message = mistral.ChatCompletionMessage(
        role: role,
        content: chatNode.content,
      );

      messages.add(message);
    }

    return messages;
  }

  List<anthropic.Message> toAnthropicMessages() {
    final List<anthropic.Message> messages = [];

    for (final chatNode in chain) {
      anthropic.MessageRole role;

      if (chatNode is UserChatNode) {
        role = anthropic.MessageRole.user;
      } else {
        role = anthropic.MessageRole.assistant;
      }

      final message = anthropic.Message(
        role: role,
        content: anthropic.MessageContent.text(chatNode.content),
      );

      messages.add(message);
    }

    return messages;
  }

  List<llama.ChatMessage> toLlamaMessages() {
    final List<llama.ChatMessage> messages = [];

    for (final chatNode in chain) {
      if (chatNode is UserChatNode) {
        messages.add(llama.UserChatMessage(chatNode.content));
      }
      else if (chatNode is AssistantChatNode) {
        messages.add(llama.AssistantChatMessage(chatNode.content));
      }
      else {
        messages.add(llama.SystemChatMessage(chatNode.content));
      }
    }

    return messages;
  }
}