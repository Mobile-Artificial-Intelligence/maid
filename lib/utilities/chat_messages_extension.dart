part of 'package:maid/main.dart';

extension ChatMessagesExtension on List<ChatMessage> {
  List<Message> toOllamaMessages() {
    final List<Message> messages = [];

    for (final ChatMessage chatMessage in this) {
      MessageRole role;
      if (chatMessage.role == 'user') {
        role = MessageRole.user;
      } else if (chatMessage.role == 'assistant') {
        role = MessageRole.assistant;
      } else {
        role = MessageRole.system;
      }

      final Message message = Message(
        role: role,
        content: chatMessage.content,
      );

      messages.add(message);
    }

    return messages;
  }
}