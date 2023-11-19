import 'package:flutter/material.dart';
import 'package:maid/pages/about_page.dart';
import 'package:maid/pages/character_page.dart';
import 'package:maid/pages/model_page.dart';
import 'package:maid/pages/session_page.dart';
import 'package:maid/pages/settings_page.dart';
import 'package:maid/static/generation_manager.dart';
import 'package:maid/widgets/chat_widgets/chat_ui.dart';
import 'package:maid/widgets/home_app_bar.dart';

class DesktopHomePage extends StatefulWidget {
  final String title;

  const DesktopHomePage({super.key, required this.title});

  @override
  DesktopHomePageState createState() => DesktopHomePageState();
}

class DesktopHomePageState extends State<DesktopHomePage> {
  int? _selectedIndex;
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NavigationRail(
          onDestinationSelected: (int index) {
            setState(() {
              if (_selectedIndex == index) {
                _selectedIndex = null;
              } else {
                _selectedIndex = index;
              }
            });
          },
          destinations: <NavigationRailDestination>[
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
        if (_selectedIndex == null)
          const Expanded(
            child: Scaffold(
              appBar: HomeAppBar(),
              body: ChatUI(),
            ),
          )
        else if (_selectedIndex == 0)
          const Expanded(child:CharacterPage())
        else if (_selectedIndex == 1)
          const Expanded(child:SessionPage())
        else if (_selectedIndex == 2)
          const Expanded(child:ModelPage())
        else if (_selectedIndex == 3)
          const Expanded(child:SettingsPage())
        else if (_selectedIndex == 4)
          const Expanded(child:AboutPage())
      ]
    );
  }
}