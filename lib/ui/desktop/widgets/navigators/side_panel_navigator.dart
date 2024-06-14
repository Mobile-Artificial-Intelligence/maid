import 'package:flutter/material.dart';
import 'package:maid/enumerators/side_panel_route.dart';
import 'package:maid/providers/desktop_layout.dart';
import 'package:maid/ui/desktop/widgets/side_panels/sessions_panel.dart';
import 'package:provider/provider.dart';

class SidePanelNavigator extends StatelessWidget {
  const SidePanelNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DesktopLayout>(
      builder: buildRoutes
    );
  }

  Widget buildRoutes(BuildContext context, DesktopLayout desktopLayout, Widget? child) {
    switch (desktopLayout.sidePanelRoute) {
      case SidePanelRoute.sessions:
        return const SessionsPanel();
      default:
        return Scaffold(
          body: Container(
            color: Theme.of(context).colorScheme.surface,
            child: Center(
              child: Text("Side Panel ${desktopLayout.sidePanelRoute.index}"),
            ),
          )
        );
    }
  }
}