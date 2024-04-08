import 'dart:math';

import 'package:flutter/material.dart';
import 'package:maid_llm/src/chat_node.dart';
import 'package:maid/providers/user.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/static/utilities.dart';
import 'package:maid/ui/mobile/widgets/chat_widgets/chat_message.dart';
import 'package:maid/ui/mobile/widgets/chat_widgets/chat_field.dart';
import 'package:maid/ui/mobile/widgets/appbars/home_app_bar.dart';
import 'package:maid/ui/mobile/widgets/home_drawer.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final ScrollController _consoleScrollController = ScrollController();
  List<ChatMessage> chatWidgets = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const HomeAppBar(),
        drawer: const HomeDrawer(),
        body: _buildBody());
  }

  Widget _buildBody() {
    return Consumer3<Session, User, Character>(
      builder: (context, session, user, character, child) {
        Map<Key, ChatRole> history = session.chat.getHistory();
        if (history.isEmpty && character.useGreeting) {
          final newKey = UniqueKey();
          final index = Random().nextInt(character.greetings.length);
          session.chat.add(
            newKey,
            content: Utilities.formatPlaceholders(character.greetings[index], user.name, character.name),
            role: ChatRole.assistant
          );
          history = {newKey: ChatRole.assistant};
        }

        chatWidgets.clear();
        for (var key in history.keys) {
          chatWidgets.add(ChatMessage(
            key: key,
            role: history[key] ?? ChatRole.assistant,
          ));
        }

        return Builder(
          builder: (BuildContext context) => GestureDetector(
            onHorizontalDragEnd: (details) {
              // Check if the drag is towards right with a certain velocity
              if (details.primaryVelocity! > 100) {
                // Open the drawer
                Scaffold.of(context).openDrawer();
              }
            },
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                  ),
                ),
                Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _consoleScrollController,
                        itemCount: chatWidgets.length,
                        itemBuilder: (BuildContext context, int index) {
                          return chatWidgets[index];
                        },
                      ),
                    ),
                    const ChatField(),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
