import 'package:flutter/material.dart';
import 'package:maid/utilities/message_manager.dart';

class BranchSwitcher extends StatefulWidget {
  const BranchSwitcher({required super.key});

  @override
  BranchSwitcherState createState() => BranchSwitcherState();
}

class BranchSwitcherState extends State<BranchSwitcher> {
  @override
  Widget build(BuildContext context) {
    int currentIndex = MessageManager.index(widget.key!);
    int siblingCount = MessageManager.siblingCount(widget.key!);

    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(0),
      width: 150,
      height: 30,
      decoration: BoxDecoration(
        color: MessageManager.busy
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            padding: const EdgeInsets.all(0),
            onPressed: () {
              if (MessageManager.busy) return;
              MessageManager.last(widget.key!);
              setState(() {});
            },
            icon: const Icon(Icons.arrow_left_rounded),
          ),
          Text('$currentIndex/${siblingCount - 1}'),
          IconButton(
            padding: const EdgeInsets.all(0),
            onPressed: () {
              if (MessageManager.busy) return;
              MessageManager.next(widget.key!);
              setState(() {});
            },
            icon: const Icon(Icons.arrow_right_rounded),
          ),
        ],
      ),
    );
  }
}
