import 'dart:math';

import 'package:flutter/material.dart';
import 'package:maid/pages/about_page.dart';
import 'package:maid/pages/character_page.dart';
import 'package:maid/pages/platform_page.dart';
import 'package:maid/pages/sessions_page.dart';
import 'package:maid/pages/settings_page.dart';
import 'package:maid/providers/character.dart';
import 'package:system_info2/system_info2.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/widgets/chat_widgets/chat_message.dart';
import 'package:maid/widgets/chat_widgets/chat_field.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  static int ram = SysInfo.getTotalPhysicalMemory() ~/ (1024 * 1024 * 1024);
  final ScrollController _consoleScrollController = ScrollController();
  List<ChatMessage> chatWidgets = [];

  AppBar _buildAppBar(double aspectRatio) {
    if (aspectRatio < 0.9) {
      return AppBar(
        elevation: 0.0,
      );
    }
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 0.0,
      titleSpacing: 0, // Remove the default spacing
      title: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceEvenly, // Distribute the space evenly
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CharacterPage()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_tree_rounded),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PlatformPage()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_rounded),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SessionsPage()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsPage()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AboutPage()));
            },
          ),
        ],
      ),
    );
  }

  Drawer? _buildDrawer(double aspectRatio) {
    if (aspectRatio < 0.9) {
      return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(
              height: 50,
            ),
            Text(
              ram == -1 ? 'RAM: Unknown' : 'RAM: $ram GB',
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    Color.lerp(Colors.red, Colors.green, ram.clamp(0, 8) / 8) ??
                        Colors.red,
                fontSize: 15,
              ),
            ),
            Divider(
              indent: 10,
              endIndent: 10,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            ListTile(
              leading: Icon(Icons.person,
                  color: Theme.of(context).colorScheme.onPrimary),
              title: Text('Character',
                  style: Theme.of(context).textTheme.labelLarge),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CharacterPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.account_tree_rounded,
                  color: Theme.of(context).colorScheme.onPrimary),
              title: Text(
                'Model',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PlatformPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.chat_rounded,
                  color: Theme.of(context).colorScheme.onPrimary),
              title: Text(
                'Sessions',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SessionsPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.settings,
                  color: Theme.of(context).colorScheme.onPrimary),
              title: Text('Settings',
                  style: Theme.of(context).textTheme.labelLarge),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.info,
                  color: Theme.of(context).colorScheme.onPrimary),
              title:
                  Text('About', style: Theme.of(context).textTheme.labelLarge),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const AboutPage()));
              },
            ),
          ],
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final aspectRatio = screenSize.width / screenSize.height;

    return Scaffold(
      appBar: _buildAppBar(aspectRatio),
      drawer: _buildDrawer(aspectRatio),
      body: Consumer2<Session, Character>(
        builder: (context, session, character, child) {
          Map<Key, bool> history = session.history();

          if (history.isEmpty && character.useGreeting) {
            final newKey = UniqueKey();
            final index = Random().nextInt(character.greetings.length);
            session.add(newKey,
                message: character.formatPlaceholders(character.greetings[index]),
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

          WidgetsBinding.instance.addPostFrameCallback((_) async {
            _consoleScrollController.animateTo(
              _consoleScrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 50),
              curve: Curves.easeOut,
            );
          });

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
                          padding: const EdgeInsets.only(
                            top: 10
                          ),
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
      ),
    );
  }
}
