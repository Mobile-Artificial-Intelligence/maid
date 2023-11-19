import 'package:flutter/material.dart';
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
        const Expanded(
          child: Scaffold(
            appBar: HomeAppBar(),
            body: ChatUI(),
          ),
        ),
      ]
    );
  }
}