import 'package:flutter/material.dart';
import 'package:maid/providers/session.dart';
import 'package:provider/provider.dart';

class SessionTile extends StatefulWidget {
  final Session session;
  final void Function() onDelete;
  final void Function(String) onRename;

  const SessionTile({super.key, required this.session, required this.onDelete, required this.onRename});

  @override
  State<SessionTile> createState() => _SessionTileState();
}

class _SessionTileState extends State<SessionTile> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) {
        String displayMessage = widget.session.name;
        if (displayMessage.length > 30) {
          displayMessage = '${displayMessage.substring(0, 30)}...';
        }

        return Semantics(
          label: 'Session Tile',
          onTapHint: 'Switch to session',
          child: GestureDetector(
            onSecondaryTapUp: onSecondaryTapUp,
            onLongPressStart: onLongPressStart,
            onTap: () {
              if (!session.chat.tail.finalised) return;
              session.from(widget.session);
            },
            child: ListTile(
              title: Text(
                displayMessage,
                style: Theme.of(context).textTheme.labelLarge,
              )
            )
          )
        );
      },
    );
  }

  void onSecondaryTapUp(TapUpDetails details) =>
      showContextMenu(details.globalPosition);

  void onLongPressStart(LongPressStartDetails details) =>
      showContextMenu(details.globalPosition);

  void showContextMenu(Offset position) {
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
          onTap: widget.onDelete,
          child: const Text('Delete'),
        ),
        PopupMenuItem(
          onTap: showRenameDialog,
          child: const Text('Rename'),
        ),
      ],
    );
  }

  void showRenameDialog() {
    final TextEditingController controller =
        TextEditingController(text: widget.session.name);

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
                widget.onRename(controller.text);

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
