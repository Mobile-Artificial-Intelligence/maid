import 'package:flutter/material.dart';
import 'package:maid/providers/desktop_navigator.dart';
import 'package:maid/ui/desktop/widgets/buttons/user_button.dart';
import 'package:provider/provider.dart';

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      padding: const EdgeInsets.symmetric(vertical: 10),
      width: 50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildTopButtons(context),
          buildBottomButtons(context),
        ],
      ),
    );
  }

  Widget buildTopButtons(BuildContext context) {
    return Column(
      children: [
        IconButton(
          tooltip: 'Toggle Side Panel',
          icon: const Icon(Icons.view_sidebar_rounded),
          onPressed: () {
            context.read<DesktopNavigator>().toggleSidePanel();
          },
        ),
        IconButton(
          tooltip: 'Sessions',
          icon: const Icon(Icons.chat_rounded),
          onPressed: () {
            DesktopNavigator.of(context).navigateSidePanel("/sessions");
          },
        ),
        IconButton(
          tooltip: 'Model Settings',
          icon: const Icon(Icons.account_tree_rounded), 
          onPressed: () {
            DesktopNavigator.of(context).navigateSidePanel("/model");
          },
        ),
        IconButton(
          tooltip: 'Characters',
          icon: const Icon(Icons.group_rounded),
          onPressed: () {
            DesktopNavigator.of(context).navigateSidePanel("/characters");
          },
        ),
      ],
    );
  }

  Widget buildBottomButtons(BuildContext context) {
    return Column(
      children: [
        IconButton(
          tooltip: 'Toggle Terminal',
          icon: const Icon(Icons.terminal_rounded),
          onPressed: () {
            DesktopNavigator.of(context).toggleSettingsPanel();
          },
        ),
        IconButton(
          tooltip: 'Toggle Settings',
          icon: const Icon(Icons.settings_rounded),
          onPressed: () {
            DesktopNavigator.of(context).toggleSettingsPanel();
          }
        ),
        const UserButton(),
      ],
    );
  }
}