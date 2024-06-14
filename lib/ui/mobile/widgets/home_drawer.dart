import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/ui/mobile/widgets/tiles/character_tile.dart';
import 'package:maid/ui/mobile/widgets/tiles/session_tile.dart';
import 'package:maid/ui/mobile/widgets/tiles/user_tile.dart';
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
      child: Consumer2<AppData, Session>(
        builder: drawerBuilder
      )
    );
  }

  Widget drawerBuilder(BuildContext context, AppData appData, Session session, Widget? child) {
    appData.currentSession = session;
    appData.save();

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
            const CharacterTile(),
            const SizedBox(height: 5.0),
            characterButtonsRow(context),
            Divider(
              color: Theme.of(context).colorScheme.primary,
            ),
            FilledButton(
              onPressed: () {
                if (!session.chat.tail.finalised) return;
                final newSession = Session();
                appData.currentSession = newSession;
                session.from(newSession);
              },
              child: const Text(
                "New Chat"
              ),
            ),
            Divider(
              color: Theme.of(context).colorScheme.primary,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: appData.sessions.length, 
                itemBuilder: (context, index) {
                  return SessionTile(
                    session: appData.sessions[index]
                  );
                }
              ),
            ),
            Divider(
              height: 0.0,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 5.0),
            const UserTile()
          ]
        )
      )
    );
  }

  Widget characterButtonsRow(BuildContext context) {
    return ListTile(
      leading: FilledButton(
        onPressed: () {
          Navigator.pop(context); // Close the drawer
          Navigator.pushNamed(
            context,
            '/character'
          );
        },
        child: const Text(
          "Customize"
        ),
      ),
      trailing: FilledButton(
        onPressed: () {
          Navigator.pop(context); // Close the drawer
          Navigator.pushNamed(
            context,
            '/characters'
          );
        },
        child: const Text(
          "Browse"
        ),
      )
    );
  }
}
