import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/providers/session.dart';
import 'package:provider/provider.dart';

class SessionTile extends StatefulWidget {
  final Session session;

  const SessionTile({
    super.key, 
    required this.session,
  });

  @override
  State<SessionTile> createState() => _SessionTileState();
}

class _SessionTileState extends State<SessionTile> {
  Timer? longPressTimer;
  late TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    controller.text = widget.session.name;

    return Consumer2<AppData, Session>(
      builder: buildGestureDetector,
    );
  }

  Widget buildGestureDetector(BuildContext context, AppData appData, Session session, Widget? child) {
    return InkWell(
      onSecondaryTapUp: (TapUpDetails details) =>
        showContextMenu(context, details.globalPosition),
      onTapDown: onTapDown,
      onTapUp: (TapUpDetails details) => onTapUp(details, appData, session),
      child: ListTile(
        title: Text(
          controller.text,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge,
        )
      ),
    );
  }

  void onTapDown(TapDownDetails details) {
    longPressTimer = Timer(const Duration(seconds: 1), () {
      showContextMenu(context, details.globalPosition);
    });
  }

  void onTapUp(TapUpDetails details, AppData appData, Session session) {
    if (longPressTimer?.isActive ?? false) {
      longPressTimer?.cancel();
      if (!session.chat.tail.finalised) return;
      appData.setCurrentSession(session, widget.session);
      session.from(widget.session);
    }
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
            final session = context.read<Session>();
            final appData = context.read<AppData>();

            if (!session.chat.tail.finalised) return;

            if (widget.session == session) {
              final newSession = appData.sessions.firstOrNull ?? Session(0);
              session.from(newSession);
              appData.addSession(newSession);
            }
            
            appData.removeSession(widget.session);
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
    showDialog(
      context: context,
      builder: buildDialog,
    );
  }

  Widget buildDialog(BuildContext context) {
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
          onPressed: () => setState(() {
            final session = context.read<Session>();

            if (widget.session == session) {
              session.name = controller.text;
            }

            widget.session.name = controller.text;

            Navigator.of(context).pop();
          }),
          child: Text(
            "Rename",
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ],
    );
  }
}
