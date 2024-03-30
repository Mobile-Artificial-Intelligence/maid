import 'package:flutter/material.dart';
import 'package:maid/classes/llama_cpp_model.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/providers/user.dart';
import 'package:maid/static/logger.dart';
import 'package:maid/static/utilities.dart';
import 'package:provider/provider.dart';
import 'package:maid_llm/maid_llm.dart';

class GenerationManager {
  static void prompt(String input, BuildContext context) async {
    context.read<Session>().busy = true;

    final user = context.read<User>();
    final character = context.read<Character>();
    final session = context.read<Session>();

    List<ChatMessage> chatMessages = [];

    final description = Utilities.formatPlaceholders(character.description, user.name, character.name);
    final personality = Utilities.formatPlaceholders(character.personality, user.name, character.name);
    final scenario = Utilities.formatPlaceholders(character.scenario, user.name, character.name);
    final system = Utilities.formatPlaceholders(character.system, user.name, character.name);

    final preprompt = '$description\n\n$personality\n\n$scenario\n\n$system';

    List<Map<String, dynamic>> messages = [
      {
        'role': 'system',
        'content': preprompt,
      }
    ];

    if (character.useExamples) {
      messages.addAll(character.examples);
    }

    messages.addAll(session.getMessages());

    for (var message in messages) {
      switch (message['role']) {
        case "user":
          chatMessages.add(ChatMessage.humanText(message['content']));
          chatMessages.add(ChatMessage.system(Utilities.formatPlaceholders(
          character.system, user.name, character.name)));
          break;
        case "assistant":
          chatMessages.add(ChatMessage.ai(message['content']));
          break;
        case "system": // Under normal circumstances, this should never be called
          chatMessages.add(ChatMessage.system(message['content']));
          break;
        default:
          break;
      }
    }

    Logger.log("Prompting with ${session.model.type.name}");

    final stream = session.model.prompt(chatMessages);

    await for (var message in stream) {
      session.stream(message);
    }
  }

  static void stop(BuildContext context) {
    final session = context.read<Session>();

    (session.model as LlamaCppModel).stop();

    Logger.log('Local generation stopped');
  }
}
