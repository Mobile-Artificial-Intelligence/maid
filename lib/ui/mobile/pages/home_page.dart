import 'dart:math';

import 'package:flutter/material.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:maid/providers/user.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/static/utilities.dart';
import 'package:maid/ui/mobile/pages/platforms/llama_cpp_page.dart';
import 'package:maid/ui/mobile/pages/platforms/mistralai_page.dart';
import 'package:maid/ui/mobile/pages/platforms/ollama_page.dart';
import 'package:maid/ui/mobile/pages/platforms/openai_page.dart';
import 'package:maid/ui/mobile/widgets/chat_widgets/chat_message.dart';
import 'package:maid/ui/mobile/widgets/chat_widgets/chat_field.dart';
import 'package:maid/ui/mobile/widgets/dropdowns/api_dropdown.dart';
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
        appBar: AppBar(
            elevation: 0.0,
            title: Row(children: [
              const ApiDropdown(),
              const Expanded(child: SizedBox()),
              IconButton(
                icon: const Icon(Icons.account_tree_rounded),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      switch (context.read<AiPlatform>().apiType) {
                        case AiPlatformType.llamacpp:
                          return const LlamaCppPage();
                        case AiPlatformType.ollama:
                          return const OllamaPage();
                        case AiPlatformType.openAI:
                          return const OpenAiPage();
                        case AiPlatformType.mistralAI:
                          return const MistralAiPage();
                        default:
                          return const LlamaCppPage();
                      }
                    }),
                  );
                },
              ),
            ])),
        drawer: const HomeDrawer(),
        body: _buildBody());
  }

  Widget _buildBody() {
    return Consumer3<Session, User, Character>(
      builder: (context, session, user, character, child) {
        Map<Key, bool> history = session.history();
        if (history.isEmpty && character.useGreeting) {
          final newKey = UniqueKey();
          final index = Random().nextInt(character.greetings.length);
          session.add(newKey,
              message: Utilities.formatPlaceholders(
                  character.greetings[index], user.name, character.name),
              userGenerated: false,
              notify: false);
          history = {newKey: false};
        }

        chatWidgets.clear();
        for (var key in history.keys) {
          chatWidgets.add(ChatMessage(
            key: key,
            userGenerated: history[key] ?? false,
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
