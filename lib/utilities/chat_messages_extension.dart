part of 'package:maid/main.dart';

extension ChatMessagesExtension on List<LlamaMessage> {
  List<ollama.Message> toOllamaMessages() {
    final List<ollama.Message> messages = [];

    for (final LlamaMessage chatMessage in this) {
      ollama.MessageRole role;
      if (chatMessage is UserLlamaMessage) {
        role = ollama.MessageRole.user;
      } else if (chatMessage is AssistantLlamaMessage) {
        role = ollama.MessageRole.assistant;
      } else {
        role = ollama.MessageRole.system;
      }

      final ollama.Message message = ollama.Message(
        role: role,
        content: chatMessage.content,
      );

      messages.add(message);
    }

    return messages;
  }

  List<open_ai.ChatCompletionMessage> toOpenAiMessages() {
    final List<open_ai.ChatCompletionMessage> messages = [];

    for (final LlamaMessage chatMessage in this) {
      if (chatMessage is UserLlamaMessage) {
        final content = open_ai.ChatCompletionUserMessageContent.string(chatMessage.content);

        final message = open_ai.ChatCompletionMessage.user(content: content);

        messages.add(message);
      }
      else if (chatMessage is AssistantLlamaMessage) {
        final message = open_ai.ChatCompletionMessage.assistant(content: chatMessage.content);

        messages.add(message);
      }
      else {
        final message = open_ai.ChatCompletionMessage.system(content: chatMessage.content);

        messages.add(message);
      }
    }

    return messages;
  }

  List<mistral.ChatCompletionMessage> toMistralMessages() {
    final List<mistral.ChatCompletionMessage> messages = [];

    for (final LlamaMessage chatMessage in this) {
      mistral.ChatCompletionMessageRole role;

      if (chatMessage is UserLlamaMessage) {
        role = mistral.ChatCompletionMessageRole.user;
      } else if (chatMessage is AssistantLlamaMessage) {
        role = mistral.ChatCompletionMessageRole.assistant;
      } else {
        role = mistral.ChatCompletionMessageRole.system;
      }

      final message = mistral.ChatCompletionMessage(
        role: role,
        content: chatMessage.content,
      );

      messages.add(message);
    }

    return messages;
  }

  List<anthropic.Message> toAnthropicMessages() {
    final List<anthropic.Message> messages = [];

    for (final LlamaMessage chatMessage in this) {
      anthropic.MessageRole role;

      if (chatMessage is UserLlamaMessage) {
        role = anthropic.MessageRole.user;
      } else {
        role = anthropic.MessageRole.assistant;
      }

      final message = anthropic.Message(
        role: role,
        content: anthropic.MessageContent.text(chatMessage.content),
      );

      messages.add(message);
    }

    return messages;
  }
}