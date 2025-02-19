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

  List<openAI.ChatCompletionMessage> toOpenAiMessages() {
    final List<openAI.ChatCompletionMessage> messages = [];

    for (final ChatMessage chatMessage in this) {
      if (chatMessage is UserChatMessage) {
        final content = openAI.ChatCompletionUserMessageContent.string(chatMessage.content);

        final message = openAI.ChatCompletionMessage.user(content: content);

        messages.add(message);
      }
      else if (chatMessage is AssistantChatMessage) {
        final message = openAI.ChatCompletionMessage.assistant(content: chatMessage.content);

        messages.add(message);
      }
      else {
        final message = openAI.ChatCompletionMessage.system(content: chatMessage.content);

        messages.add(message);
      }
    }

    return messages;
  }
}