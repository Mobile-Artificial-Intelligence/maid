part of 'package:maid/main.dart';

extension ChatMessagesExtension on ChatMessage {
  List<llama.LlamaMessage> toLlamaMessages() {
    final List<llama.LlamaMessage> messages = [];

    ChatMessage currentMessage = this;
    do {
      String role;
      switch (currentMessage.role) {
        case ChatMessageRole.user:
          role = 'user';
          break;
        case ChatMessageRole.assistant:
          role = 'assistant';
          break;
        case ChatMessageRole.system:
          role = 'system';
          break;
      }

      messages.add(llama.LlamaMessage.withRole(
        role: role,
        content: currentMessage.content,
      ));

      currentMessage = currentMessage.currentChild!;
    } while (currentMessage.currentChild != null);

    return messages;
  }

  List<ollama.Message> toOllamaMessages() {
    final List<ollama.Message> messages = [];

    ChatMessage currentMessage = this;
    do {
      ollama.MessageRole role;
      switch (currentMessage.role) {
        case ChatMessageRole.user:
          role = ollama.MessageRole.user;
          break;
        case ChatMessageRole.assistant:
          role = ollama.MessageRole.assistant;
          break;
        case ChatMessageRole.system:
          role = ollama.MessageRole.system;
          break;
      }

      messages.add(ollama.Message(
        role: role,
        content: currentMessage.content,
      ));

      currentMessage = currentMessage.currentChild!;
    } while (currentMessage.currentChild != null);

    return messages;
  }

  List<open_ai.ChatCompletionMessage> toOpenAiMessages() {
    final List<open_ai.ChatCompletionMessage> messages = [];

    ChatMessage currentMessage = this;
    do {
      open_ai.ChatCompletionMessage message;
      switch (currentMessage.role) {
        case ChatMessageRole.user:
          final content = open_ai.ChatCompletionUserMessageContent.string(currentMessage.content);
          message = open_ai.ChatCompletionMessage.user(content: content);
          break;
        case ChatMessageRole.assistant:
          message = open_ai.ChatCompletionMessage.assistant(content: currentMessage.content);
          break;
        case ChatMessageRole.system:
          message = open_ai.ChatCompletionMessage.system(content: currentMessage.content);
          break;
      }

      messages.add(message);

      currentMessage = currentMessage.currentChild!;
    } while (currentMessage.currentChild != null);

    return messages;
  }

  List<mistral.ChatCompletionMessage> toMistralMessages() {
    final List<mistral.ChatCompletionMessage> messages = [];

    ChatMessage currentMessage = this;
    do {
      mistral.ChatCompletionMessageRole role;
      switch (currentMessage.role) {
        case ChatMessageRole.user:
          role = mistral.ChatCompletionMessageRole.user;
          break;
        case ChatMessageRole.assistant:
          role = mistral.ChatCompletionMessageRole.assistant;
          break;
        case ChatMessageRole.system:
          role = mistral.ChatCompletionMessageRole.system;
          break;
      }

      final message = mistral.ChatCompletionMessage(
        role: role,
        content: currentMessage.content,
      );

      messages.add(message);

      currentMessage = currentMessage.currentChild!;
    } while (currentMessage.currentChild != null);

    return messages;
  }

  List<anthropic.Message> toAnthropicMessages() {
    final List<anthropic.Message> messages = [];

    ChatMessage currentMessage = this;
    do {
      anthropic.MessageRole role;
      switch (currentMessage.role) {
        case ChatMessageRole.user:
          role = anthropic.MessageRole.user;
          break;
        case ChatMessageRole.assistant:
          role = anthropic.MessageRole.assistant;
          break;
        case ChatMessageRole.system:
          role = anthropic.MessageRole.assistant;
          break;
      }

      final message = anthropic.Message(
        role: role,
        content: anthropic.MessageContent.text(currentMessage.content),
      );

      messages.add(message);

      currentMessage = currentMessage.currentChild!;
    } while (currentMessage.currentChild != null);

    return messages;
  }
}