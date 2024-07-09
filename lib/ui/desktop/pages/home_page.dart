import 'package:flutter/material.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:maid/classes/providers/desktop_navigator.dart';
import 'package:maid/ui/desktop/layout/home_app_bar.dart';
import 'package:maid/ui/desktop/navigators/side_panel_navigator.dart';
import 'package:maid/ui/desktop/layout/side_bar.dart';
import 'package:maid/ui/shared/chat_widgets/chat_body.dart';
import 'package:provider/provider.dart';

class DesktopHomePage extends StatefulWidget {
  const DesktopHomePage({super.key});

  @override
  State<DesktopHomePage> createState() => _DesktopHomePageState();
}

class _DesktopHomePageState extends State<DesktopHomePage> {
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
    return Row(
      children: [
        const SideBar(),
        Expanded(child: buildResizableContainer(context))
      ]
    );
  }

  Widget buildResizableContainer(BuildContext context) {
    return Consumer<DesktopNavigator>(
      builder: (context, desktopNavigator, child) {
        if (desktopNavigator.sidePanelRoute == null) {
          return buildHomePanel();
        }

        return ResizableContainer(
          direction: Axis.horizontal,
          divider: ResizableDivider(
            color: dividerColor,
            size: 4,
            thickness: 3,
            onHoverEnter: onHoverEnter,
            onHoverExit: onHoverExit,
          ),
          children: [
            const ResizableChild(
              size: ResizableSize.ratio(0.2),
              child: SidePanelNavigator(),
            ),
            ResizableChild(
              size: const ResizableSize.ratio(0.8),
              child: buildHomePanel(),
            ),
          ]
        );
      }
    );
  }

  Widget buildHomePanel() {
    return const Scaffold(
      appBar: HomeAppBar(),
      body: ChatBody(),
    );
  }
}
