import 'dart:math';

import 'package:flutter/material.dart';
import 'package:maid/classes/chat_node.dart';
import 'package:maid/providers/user.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/static/utilities.dart';
import 'package:maid/ui/mobile/widgets/chat_widgets/chat_message.dart';
import 'package:maid/ui/mobile/widgets/chat_widgets/chat_field.dart';
import 'package:maid/ui/mobile/widgets/appbars/home_app_bar.dart';
import 'package:maid/ui/mobile/widgets/home_drawer.dart';
import 'package:provider/provider.dart';

class MobileHomePage extends StatefulWidget {
  const MobileHomePage({super.key});

  @override
  State<MobileHomePage> createState() => _MobileHomePageState();
}

class _MobileHomePageState extends State<MobileHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppBar(),
      drawer: const HomeDrawer(),
      body: _buildBody()
    );
  }

  Widget _buildBody() {
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
    return Consumer3<Session, User, Character>(
      builder: (context, session, user, character, child) {
        session.save();
        
        List<ChatNode> chat = session.chat.getChat();

        if (
          chat.isEmpty && 
          character.useGreeting && 
          character.greetings.isNotEmpty
        ) {
          final index = Random().nextInt(character.greetings.length);

          if (character.greetings[index].isNotEmpty) {
            final message = ChatNode(
              role: ChatRole.assistant,
              content: Utilities.formatPlaceholders(character.greetings[index], user.name, character.name),
              finalised: true
            );

            session.chat.addNode(message);
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
