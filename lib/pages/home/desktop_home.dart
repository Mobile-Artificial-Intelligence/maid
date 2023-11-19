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
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.person),
                selectedIcon: Icon(Icons.person),
                label: Text('Character'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.chat_rounded),
                selectedIcon: Icon(Icons.chat_rounded),
                label: Text('Sessions'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.account_tree_rounded),
                selectedIcon: Icon(Icons.account_tree_rounded),
                label: Text('Model')
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.info),
                selectedIcon: Icon(Icons.info),
                label: Text('About'),
              ),
            ], 
            selectedIndex: null,
          ),
          const ChatUI()
        ]
      ),
    );
  }
}