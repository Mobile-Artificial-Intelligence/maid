import 'package:flutter/material.dart';
import 'package:maid/providers/session.dart'; // Make sure this is your actual path
import 'package:maid/static/logger.dart'; // Make sure this is your actual path
import 'package:provider/provider.dart';

class SessionTile extends StatefulWidget {
  final Session session;
  final void Function(Key) onDelete;

  const SessionTile({super.key, required this.session, required this.onDelete});

  @override
  State<SessionTile> createState() => _SessionTileState();
}

class _SessionTileState extends State<SessionTile> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) {
        String displayMessage = widget.session.rootMessage;
        if (displayMessage.length > 15) {
          displayMessage = '${displayMessage.substring(0, 15)}...';
        }

        return ListTile(
          title: Text(
            displayMessage,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          onTap: () {
            if (session.isBusy) return;
            session.fromMap(widget.session.toMap());
          },
          onLongPress: () {
            if (session.isBusy) return;
            _showContextMenu(context, session);
          },
        );
      },
    );
  }

  void _showContextMenu(BuildContext context, Session session) {
    final TextEditingController controller =
        TextEditingController(text: widget.session.rootMessage);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                widget.onDelete(widget.session.key);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename'),
              onTap: () {
                Navigator.of(context).pop(); // Close the modal bottom sheet
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
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "Cancel",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        FilledButton(
                          onPressed: () {
                            String oldName = session.rootMessage;
                            Logger.log(
                                "Updating session $oldName ====> ${controller.text}");
                            session.setRootMessage(controller.text);
                            Navigator.of(context).pop();
                            setState(() {});
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
              },
            ),
          ],
        );
      },
    );
  }
}
