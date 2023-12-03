import 'package:flutter/material.dart';
import 'package:maid/widgets/page_bodies/about_body.dart';
import 'package:maid/widgets/page_bodies/character_body.dart';
import 'package:maid/widgets/page_bodies/chat_body.dart';
import 'package:maid/widgets/page_bodies/model_body.dart';
import 'package:maid/widgets/page_bodies/sessions_body.dart';
import 'package:maid/widgets/page_bodies/settings_body.dart';

class DesktopHomePage extends StatefulWidget {
  final String title;

  const DesktopHomePage({super.key, required this.title});

  @override
  DesktopHomePageState createState() => DesktopHomePageState();
}

class DesktopHomePageState extends State<DesktopHomePage> {
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
  
  @override
  Widget build(BuildContext context) {
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
      ]
    );
  }
}