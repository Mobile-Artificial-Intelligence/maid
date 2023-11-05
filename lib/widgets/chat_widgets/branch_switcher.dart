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

    return SizedBox(
      width: 120,
      height: 40,
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  MessageManager.last(widget.key!);
                  setState(() {});
                },
                icon: const Icon(Icons.arrow_left),
              ),
              Text('$currentIndex/${siblingCount-1}'),
              IconButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  MessageManager.next(widget.key!);
                  setState(() {});
                },
                icon: const Icon(Icons.arrow_right),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
