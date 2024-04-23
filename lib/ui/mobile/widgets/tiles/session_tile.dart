import 'package:flutter/material.dart';
import 'package:maid/providers/session.dart'; // Ensure this is your actual path
import 'package:maid/static/logger.dart'; // Ensure this is your actual path
import 'package:provider/provider.dart';

class SessionTile extends StatefulWidget {
  final Session session;
  final void Function() onDelete;

  const SessionTile({super.key, required this.session, required this.onDelete});

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

        return GestureDetector(
          onSecondaryTapUp: _onSecondaryTapUp,
          onLongPressStart: _onLongPressStart,
          onTap: () {
            if (!session.chat.tail.finalised) return;
            session.from(widget.session);
          },
          child: ListTile(
              title: Text(
            displayMessage,
            style: Theme.of(context).textTheme.labelLarge,
          )),
        );
      },
    );
  }

  void _onSecondaryTapUp(TapUpDetails details) =>
      _showContextMenu(details.globalPosition);

  void _onLongPressStart(LongPressStartDetails details) =>
      _showContextMenu(details.globalPosition);

  void _showContextMenu(Offset position) {
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
          child: const Text('Delete'),
          onTap: () {
            Navigator.of(context).pop(); // Close the menu first
            widget.onDelete();
          },
        ),
        PopupMenuItem(
          child: const Text('Rename'),
          onTap: () {
            Navigator.of(context).pop(); // Close the menu first
            // Delayed execution to allow the popup menu to close properly
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showRenameDialog();
            });
          },
        ),
      ],
    );
  }

  void _showRenameDialog() {
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
                String oldName = widget.session.name;
                Logger.log(
                    "Updating session $oldName ====> ${controller.text}");
                widget.session.name = controller.text;
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
