part of 'package:maid/main.dart';

extension ChatMessagesExtension on List<ChatMessage> {
  List<ollama.Message> toOllamaMessages() {
    final List<ollama.Message> messages = [];

    for (final ChatMessage chatMessage in this) {
      ollama.MessageRole role;
      if (chatMessage is UserChatMessage) {
        role = ollama.MessageRole.user;
      } else if (chatMessage is AssistantChatMessage) {
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

    for (final ChatMessage chatMessage in this) {
      if (chatMessage is UserChatMessage) {
        final content = open_ai.ChatCompletionUserMessageContent.string(chatMessage.content);

        final message = open_ai.ChatCompletionMessage.user(content: content);

        messages.add(message);
      }
      else if (chatMessage is AssistantChatMessage) {
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

    for (final ChatMessage chatMessage in this) {
      mistral.ChatCompletionMessageRole role;

      if (chatMessage is UserChatMessage) {
        role = mistral.ChatCompletionMessageRole.user;
      } else if (chatMessage is AssistantChatMessage) {
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
}