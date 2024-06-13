import 'package:flutter/material.dart';
import 'package:maid/providers/desktop_layout.dart';
import 'package:provider/provider.dart';

class SidePanelNavigator extends StatefulWidget {
  const SidePanelNavigator({super.key});

  @override
  State<SidePanelNavigator> createState() => _SidePanelNavigatorState();
}

class _SidePanelNavigatorState extends State<SidePanelNavigator> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DesktopLayout>(
      builder: (context, desktopLayout, child) {
        return Scaffold(
          body: Container(
            color: Theme.of(context).colorScheme.surface,
            child: Center(
              child: Text("Side Panel ${desktopLayout.sidePanelRoute.index}"),
            ),
          )
        );
      },
    );
  }
}