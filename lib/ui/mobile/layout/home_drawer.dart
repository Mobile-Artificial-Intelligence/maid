import 'package:flutter/material.dart';
import 'package:maid/classes/providers/characters.dart';
import 'package:maid/ui/shared/tiles/character_tile.dart';
import 'package:maid/ui/shared/buttons/clear_sessions_button.dart';
import 'package:maid/ui/shared/views/sessions_list_view.dart';
import 'package:maid/ui/mobile/tiles/user_tile.dart';
import 'package:provider/provider.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: "Drawer Menu",
      onTapHint: "Close Drawer",
      onTap: () {
        Navigator.pop(context);
      },
      child: Consumer<CharacterCollection>(
        builder: drawerBuilder
      )
    );
  }

  Widget drawerBuilder(BuildContext context, CharacterCollection characters, Widget? child) {
    return Drawer(
      semanticLabel: "Drawer Menu",
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20)
        ),
      ),
      child: SafeArea(
        minimum: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Expanded(
            //   child: CharacterTile(
            //     character: characters.current,
            //   )
            // ),
            const SizedBox(height: 5.0),
            FilledButton(
              onPressed: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(
                  context,
                  '/characters'
                );
              },
              child: const Text(
                "Browse Characters"
              ),
            ),
            Divider(
              color: Theme.of(context).colorScheme.primary,
            ),
            const Expanded(
              child: SessionsListView()
            ),
            const ClearSessionsButton(),
            Divider(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 5.0),
            const UserTile()
          ]
        )
      )
    );
  }
}
