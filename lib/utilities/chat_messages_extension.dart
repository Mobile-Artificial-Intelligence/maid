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

  List<openai.ChatCompletionMessage> toOpenAiMessages() {
    final List<openai.ChatCompletionMessage> messages = [];

    for (final ChatMessage chatMessage in this) {
      if (chatMessage is UserChatMessage) {
        final content = openai.ChatCompletionUserMessageContent.string(chatMessage.content);

        final message = openai.ChatCompletionMessage.user(content: content);

        messages.add(message);
      }
      else if (chatMessage is AssistantChatMessage) {
        final message = openai.ChatCompletionMessage.assistant(content: chatMessage.content);

        messages.add(message);
      }
      else {
        final message = openai.ChatCompletionMessage.system(content: chatMessage.content);

        messages.add(message);
      }
    }

    return messages;
  }
}