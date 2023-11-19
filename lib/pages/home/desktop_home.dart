import 'package:flutter/material.dart';
import 'package:maid/widgets/chat_widgets/chat_ui.dart';

class DesktopHomePage extends StatefulWidget {
  final String title;

  const DesktopHomePage({super.key, required this.title});

  @override
  DesktopHomePageState createState() => DesktopHomePageState();
}

class DesktopHomePageState extends State<DesktopHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            destinations: <NavigationRailDestination>[
              NavigationRailDestination(
                icon: const Icon(Icons.person),
                selectedIcon: const Icon(Icons.person),
                indicatorColor: Theme.of(context).colorScheme.tertiary,
                label: const Text('Character'),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.chat_rounded),
                selectedIcon: const Icon(Icons.chat_rounded),
                indicatorColor: Theme.of(context).colorScheme.tertiary,
                label: const Text('Sessions'),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.account_tree_rounded),
                selectedIcon: const Icon(Icons.account_tree_rounded),
                indicatorColor: Theme.of(context).colorScheme.tertiary,
                label: const Text('Model')
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.settings),
                selectedIcon: const Icon(Icons.settings),
                indicatorColor: Theme.of(context).colorScheme.tertiary,
                label: const Text('Settings'),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.info),
                selectedIcon: const Icon(Icons.info),
                indicatorColor: Theme.of(context).colorScheme.tertiary,
                label: const Text('About'),
              ),
            ], 
            selectedIndex: null,
          ),
          const Expanded(
            child: ChatUI(),
          ),
        ]
      ),
    );
  }
}