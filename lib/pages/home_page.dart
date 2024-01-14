import 'package:flutter/material.dart';
import 'package:maid/pages/generic_page.dart';
import 'package:maid/widgets/page_bodies/about_body.dart';
import 'package:maid/widgets/page_bodies/character_body.dart';
import 'package:maid/widgets/page_bodies/chat_body.dart';
import 'package:maid/widgets/page_bodies/model_body.dart';
import 'package:maid/widgets/page_bodies/sessions_body.dart';
import 'package:maid/widgets/page_bodies/settings_body.dart';

import 'package:system_info2/system_info2.dart';

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  static int ram = SysInfo.getTotalPhysicalMemory() ~/ (1024 * 1024 * 1024);

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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute the space evenly
            children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GenericPage(title: "Character", body: CharacterBody())
                      )
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.chat_rounded),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GenericPage(title: "Sessions", body: SessionsBody())
                      )
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.account_tree_rounded),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GenericPage(title: "Model", body: ModelBody())
                      )
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GenericPage(title: "Settings", body: SettingsBody())
                      )
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.info),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GenericPage(title: "About", body: AboutBody())
                      )
                    );
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
              title: Text(
                'Character',
                style: Theme.of(context).textTheme.labelLarge),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GenericPage(title: "Character", body: CharacterBody())));
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
                    builder: (context) => const GenericPage(title: "Sessions", body: SessionsBody())
                  )
                );
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
                    builder: (context) => const GenericPage(title: "Model", body: ModelBody())
                  )
                );
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
                    builder: (context) => const GenericPage(title: "Settings", body: SettingsBody())
                  )
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.info,
                  color: Theme.of(context).colorScheme.onPrimary),
              title:
                  Text('About', style: Theme.of(context).textTheme.labelLarge),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GenericPage(title: "About", body: AboutBody())
                  )
                );
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
      body: const ChatBody(),
    );
  }
}