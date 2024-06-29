import 'package:flutter/material.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:maid/classes/providers/desktop_navigator.dart';
import 'package:provider/provider.dart';

class SidePanelNavigator extends StatefulWidget {
  const SidePanelNavigator({super.key});

  @override
  State<SidePanelNavigator> createState() => _SidePanelNavigatorState();
}

class _SidePanelNavigatorState extends State<SidePanelNavigator> {
  late Color dividerColor = Theme.of(context).colorScheme.primary;

  void onHoverEnter() {
    setState(() {
      dividerColor = Theme.of(context).colorScheme.secondary;
    });
  }

  void onHoverExit() {
    setState(() {
      dividerColor = Theme.of(context).colorScheme.primary;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DesktopNavigator>(
      builder: buildRoutes
    );
  }

  Widget buildRoutes(BuildContext context, DesktopNavigator desktopNavigator, Widget? child) {
    if (desktopNavigator.settingsPanelRoute == null) {
      return desktopNavigator.sidePanelRoute!(context);
    }

    return ResizableContainer(
      direction: Axis.vertical,
      divider: ResizableDivider(
        color: dividerColor,
        size: 4,
        thickness: 3,
        onHoverEnter: onHoverEnter,
        onHoverExit: onHoverExit,
      ),
      children: [
        ResizableChild(
          size: const ResizableSize.ratio(0.7),
          minSize: 500,
          child: desktopNavigator.sidePanelRoute!(context),
        ),
        ResizableChild(
          size: const ResizableSize.ratio(0.3),
          minSize: 300,
          child: desktopNavigator.settingsPanelRoute!(context),
        ),
      ]
    );
  }
}