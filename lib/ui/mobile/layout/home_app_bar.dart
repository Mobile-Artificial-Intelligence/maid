import 'package:flutter/material.dart';
import 'package:maid/ui/mobile/buttons/menu_button.dart';
import 'package:maid/ui/shared/buttons/new_session_button.dart';
import 'package:maid/ui/shared/dropdowns/llm_platform_dropdown.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      title: const LlmPlatformDropdown(),
      centerTitle: false,
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: NewSessionButton(),
        ),
        Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: MenuButton(),
        ),
      ],
    );
  }
}
