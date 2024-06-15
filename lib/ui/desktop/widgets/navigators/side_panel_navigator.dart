import 'package:flutter/material.dart';
import 'package:maid/enumerators/side_panel_route.dart';
import 'package:maid/providers/desktop_navigator.dart';
import 'package:maid/ui/desktop/widgets/side_panels/characters_panel.dart';
import 'package:maid/ui/desktop/widgets/side_panels/sessions_panel.dart';
import 'package:provider/provider.dart';

class SidePanelNavigator extends StatelessWidget {
  const SidePanelNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DesktopNavigator>(
      builder: buildRoutes
    );
  }

  Widget buildRoutes(BuildContext context, DesktopNavigator DesktopNavigator, Widget? child) {
    switch (DesktopNavigator.sidePanelRoute) {
      case SidePanelRoute.sessions:
        return const SessionsPanel();
      case SidePanelRoute.characters:
        return const CharactersPanel();
      default:
        return Scaffold(
          body: Container(
            color: Theme.of(context).colorScheme.surface,
            child: Center(
              child: Text("Side Panel ${DesktopNavigator.sidePanelRoute.index}"),
            ),
          )
        );
    }
  }
}