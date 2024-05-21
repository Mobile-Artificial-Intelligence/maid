import 'package:flutter/material.dart';
import 'package:maid/providers/session.dart';
import 'package:provider/provider.dart';

class ChatBranchSwitcher extends StatefulWidget {
  final String hash;

  const ChatBranchSwitcher({
    super.key,
    required this.hash,
  });

  @override
  State<ChatBranchSwitcher> createState() => _ChatBranchSwitcherState();
}

class _ChatBranchSwitcherState extends State<ChatBranchSwitcher> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (BuildContext context, Session session, Widget? child) {
        int currentIndex = session.chat.indexOf(widget.hash);
        int siblingCount = session.chat.siblingCountOf(widget.hash);

        return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              padding: const EdgeInsets.all(0),
              onPressed: () {
                if (!session.chat.tail.finalised) return;
                session.chat.last(widget.hash);
                session.notify();
              },
              icon: Icon(
                Icons.arrow_left,
                color: Theme.of(context).colorScheme.onPrimary
              )
            ),
            Text(
              '${currentIndex + 1}/$siblingCount',
              style: Theme.of(context).textTheme.labelLarge
            ),
            IconButton(
              padding: const EdgeInsets.all(0),
              onPressed: () {
                if (!session.chat.tail.finalised) return;
                session.chat.next(widget.hash);
                session.notify();
              },
              icon: Icon(
                Icons.arrow_right,
                color: Theme.of(context).colorScheme.onPrimary
              ),
            ),
          ],
        );
      },
    );
  }
}