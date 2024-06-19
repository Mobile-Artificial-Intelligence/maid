import 'package:flutter/material.dart';
import 'package:maid/ui/mobile/buttons/menu_button.dart';
import 'package:maid/ui/shared/dropdowns/llm_platform_dropdown.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          leadWidgets(context),
          const MenuButton(),
        ],
      ),
    );
  }

  Widget leadWidgets(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            Scaffold.of(context).openDrawer();
          }, 
          icon: const Icon(Icons.menu),
        ),
        const LlmPlatformDropdown(),
      ],
    );
  }
}
