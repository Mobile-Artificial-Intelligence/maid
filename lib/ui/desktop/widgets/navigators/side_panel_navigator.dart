import 'package:flutter/material.dart';
import 'package:maid/providers/desktop_navigator.dart';
import 'package:provider/provider.dart';

class SidePanelNavigator extends StatelessWidget {
  const SidePanelNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DesktopNavigator>(
      builder: buildRoutes
    );
  }

  Widget buildRoutes(BuildContext context, DesktopNavigator desktopNavigator, Widget? child) {
    return desktopNavigator.sidePanelRoute(context);
  }
}