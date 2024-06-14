import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/providers/session.dart';
import 'package:provider/provider.dart';

class SessionTile extends StatelessWidget {
  final Session session;

  const SessionTile({
    super.key, 
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, globalSession, child) {
        return GestureDetector(
          onSecondaryTapUp: (TapUpDetails details) =>
            showContextMenu(context, details.globalPosition),
          onLongPressStart: (LongPressStartDetails details) =>
            showContextMenu(context, details.globalPosition),
          onTap: () {
            if (!globalSession.chat.tail.finalised) return;
            globalSession.from(session);
          },
          child: ListTile(
            title: Text(
              session.name,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge,
            )
          ),
        );
      },
    );
  }

  void showContextMenu(BuildContext context, Offset position) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(40, 40), // smaller rect, the touch area
        Offset.zero & overlay.size, // Bigger rect, the entire screen
      ),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          onTap: () {
            final globalSession = context.read<Session>();
            final appData = context.read<AppData>();

            if (!globalSession.chat.tail.finalised) return;

            if (session.key == globalSession.key) {
              final newSession = appData.sessions.firstOrNull ?? Session();
              globalSession.from(newSession);
              appData.currentSession = newSession;
            }
            
            appData.removeSession(session);
          },
          child: const Text('Delete'),
        ),
        PopupMenuItem(
          onTap: () => showRenameDialog(context),
          child: const Text('Rename'),
        ),
      ],
    );
  }

  void showRenameDialog(BuildContext context) {
    final TextEditingController controller =
        TextEditingController(text: session.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Rename Session",
            textAlign: TextAlign.center,
          ),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Enter new name",
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            FilledButton(
              onPressed: () {
                final globalSession = context.read<Session>();

                if (session.key == globalSession.key) {
                  globalSession.name = controller.text;
                }

                session.name = controller.text;

                context.read<AppData>().updateSession(session);

                Navigator.of(context).pop();
              },
              child: Text(
                "Rename",
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ],
        );
      },
    );
  }
}
