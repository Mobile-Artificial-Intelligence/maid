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
  int _selectedIndex = 0;

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return const Expanded(
          child: Scaffold(
            body: ChatBody(),
          ),
        );
      case 1:
        return const Expanded(child: Scaffold(body: CharacterBody()));
      case 2:
        return const Expanded(child: Scaffold(body: SessionsBody()));
      case 3:
        return const Expanded(child: Scaffold(body: ModelBody()));
      case 4:
        return const Expanded(child: Scaffold(body: SettingsBody()));
      case 5:
        return const Expanded(child: Scaffold(body: AboutBody()));
      default: 
        return const Expanded(
          child: Scaffold(
            body: ChatBody(),
          ),
        );
    }
  }

  AppBar? _buildAppBar(double aspectRatio) {
    if (aspectRatio < 0.9) {
      return AppBar(
        elevation: 0.0,
      );
    }
    return null;
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

  Widget _buildBody(double aspectRatio) {
    if (aspectRatio < 0.9) {
      return const ChatBody();
    }
    return Row(
      children: [
        NavigationRail(
          onDestinationSelected: (int index) {
            setState(() {
              if (_selectedIndex != index) {
                _selectedIndex = index;
              }
            });
          },
          destinations: const <NavigationRailDestination>[
             NavigationRailDestination(
              icon: Icon(Icons.home),
              selectedIcon: Icon(
                Icons.home,
              ),
              label: Text('Home'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.person),
              selectedIcon: Icon(
                Icons.person,
              ),
              label: Text('Character'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.chat_rounded),
              selectedIcon: Icon(
                Icons.chat_rounded,
              ),
              label: Text('Sessions'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.account_tree_rounded),
              selectedIcon: Icon(
                Icons.account_tree_rounded,
              ),
              label: Text('Model')
            ),
            NavigationRailDestination(
              icon: Icon(Icons.settings),
              selectedIcon: Icon(
                Icons.settings,
              ),
              label: Text('Settings'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.info),
              selectedIcon: Icon(
                Icons.info,
              ),
              label: Text('About'),
            ),
          ],
          selectedIndex: _selectedIndex,
        ),
        _getSelectedPage(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final aspectRatio = screenSize.width / screenSize.height;

    return Scaffold(
      appBar: _buildAppBar(aspectRatio),
      drawer: _buildDrawer(aspectRatio),
      body: _buildBody(aspectRatio),
    );
  }
}