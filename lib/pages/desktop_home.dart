import 'package:flutter/material.dart';
import 'package:maid/widgets/home_app_bar.dart';
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
            appBar: HomeAppBar(),
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
            appBar: HomeAppBar(),
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
          destinations: <NavigationRailDestination>[
            NavigationRailDestination(
              icon: const Icon(Icons.home),
              selectedIcon: Icon(
                Icons.home,
                color: Theme.of(context).colorScheme.secondary,
              ),
              label: const Text('Home'),
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.person),
              selectedIcon: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.secondary,
              ),
              label: const Text('Character'),
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.chat_rounded),
              selectedIcon: Icon(
                Icons.chat_rounded,
                color: Theme.of(context).colorScheme.secondary,
              ),
              label: const Text('Sessions'),
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.account_tree_rounded),
              selectedIcon: Icon(
                Icons.account_tree_rounded,
                color: Theme.of(context).colorScheme.secondary,
              ),
              label: const Text('Model')
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.settings),
              selectedIcon: Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.secondary,
              ),
              label: const Text('Settings'),
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.info),
              selectedIcon: Icon(
                Icons.info,
                color: Theme.of(context).colorScheme.secondary,
              ),
              label: const Text('About'),
            ),
          ], 
          selectedIndex: _selectedIndex,
        ),
        _getSelectedPage(),
      ]
    );
  }
}