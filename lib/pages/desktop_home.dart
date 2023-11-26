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
        return Expanded(
          child: Scaffold(
            appBar: const HomeAppBar(),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: calculatePadding()),
              child: const ChatBody(),
            ),
          ),
        );
      case 1:
        return Expanded(
          child: Scaffold(
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: calculatePadding()),
              child: const CharacterBody(),
            ),
          ),
        );
      case 2:
        return Expanded(
          child: Scaffold(
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: calculatePadding()),
              child: const SessionsBody(),
            ),
          ),
        );
      case 3:
        return Expanded(
          child: Scaffold(
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: calculatePadding()),
              child: const ModelBody(),
            ),
          ),
        );
      case 4:
      return Expanded(
        child: Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: calculatePadding()),
            child: const SettingsBody(),
          ),
        ),
      );
      case 5:
      return Expanded(
        child: Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: calculatePadding()),
            child: const AboutBody(),
          ),
        ),
      );
      default: 
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: calculatePadding()),
            child: const Scaffold(
              body: ChatBody(),
            ),
          ),
        );
        
    }
  }

double calculatePadding() {
  double screenWidth = MediaQuery.of(context).size.width;
  double baseScreenWidth = 640.0;
  double basePaddingPercent = 0.05; // 5%
  double scaleFactor = 0.015; // Adjust this to control how much extra padding is added per pixel

  double additionalPadding = (screenWidth - baseScreenWidth) * scaleFactor;
  additionalPadding = additionalPadding.clamp(0, 0.27); // Ensure the additional padding stays within a reasonable range

  double calculatedPadding = basePaddingPercent + additionalPadding;
  calculatedPadding = calculatedPadding.clamp(0.05, 0.32); // Clamp the final padding percentage between 5% and 32%

  return screenWidth * calculatedPadding;
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
