import 'package:flutter/material.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/static/logger.dart';
import 'package:provider/provider.dart';

class SessionTile extends StatefulWidget {
  final Session session;

  const SessionTile({super.key, required this.session});

  @override
  State<SessionTile> createState() => _SessionTileState();
}

class _SessionTileState extends State<SessionTile> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) {
        return ListTile(
          title: Text(
            widget.session.rootMessage,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          onTap: () {
            if (session.isBusy) return;
            session.fromMap(widget.session.toMap());
          },
          onLongPress: () {
            if (session.isBusy) return;
            showDialog(
              context: context,
              builder: (context) {
                final TextEditingController controller =
                    TextEditingController(text: widget.session.rootMessage);
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
        );
      },
    );
  }
}
