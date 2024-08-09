import 'dart:math';

import 'package:flutter/material.dart';
import 'package:maid/classes/chat_node.dart';
import 'package:maid/classes/providers/characters.dart';
import 'package:maid/classes/providers/sessions.dart';
import 'package:maid/classes/providers/user.dart';
import 'package:maid/enumerators/chat_role.dart';
import 'package:maid/classes/static/utilities.dart';
import 'package:maid/ui/shared/chat_widgets/chat_field.dart';
import 'package:maid/ui/shared/chat_widgets/chat_message.dart';
import 'package:provider/provider.dart';

class ChatBody extends StatelessWidget {
  const ChatBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _buildChat(),
        ),
        const ChatField(),
      ],
    );
  }

  List<ChatMessageWidget> _getChatWidgets(List<ChatNode> chat) {
    List<ChatMessageWidget> chatWidgets = [];

    for (final message in chat) {
      chatWidgets.add(ChatMessageWidget(hash: message.hash));
    }

    return chatWidgets;
  }

  Widget _buildChat() {
    return Consumer3<Sessions, CharacterCollection, User>(
      builder: (context, sessions, characters, user, child) {
        List<ChatNode> chat = sessions.current.chat.getChat();

        if (
          chat.isEmpty && 
          characters.current.useGreeting && 
          characters.current.greetings.isNotEmpty
        ) {
          final index = Random().nextInt(characters.current.greetings.length);

          if (characters.current.greetings[index].isNotEmpty) {
            final message = ChatNode(
              role: ChatRole.assistant,
              content: Utilities.formatPlaceholders(characters.current.greetings[index], user.name, characters.current.name),
              finalised: true
            );

            sessions.current.chat.addNode(message);
            chat = [message];
          }
        }

        final chatWidgets = _getChatWidgets(chat);

        return Builder(
          builder: (BuildContext context) => GestureDetector(
            onHorizontalDragEnd: (details) {
              // Check if the drag is towards right with a certain velocity
              if (details.primaryVelocity! > 100) {
                // Open the drawer
                Scaffold.of(context).openDrawer();
              }
            },
            child: ListView.builder(
              itemCount: chatWidgets.length,
              itemBuilder: (BuildContext context, int index) {
                return chatWidgets[index];
              },
            )
          ),
        );
      },
    );
  }
}