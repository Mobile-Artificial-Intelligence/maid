import 'package:flutter/material.dart';
import 'package:maid/ui/mobile/widgets/buttons/menu_button.dart';
import 'package:maid/ui/mobile/widgets/dropdowns/llm_dropdown.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      elevation: 0.0,
      actions: const [
        SizedBox(width: 50),
        LlmDropdown(),
        Expanded(child: SizedBox()),
        MenuButton()
      ],
    );
  }
}
