import 'package:flutter/material.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:maid/providers/desktop_navigator.dart';
import 'package:maid/ui/desktop/widgets/appbars/home_app_bar.dart';
import 'package:maid/ui/desktop/widgets/navigators/side_panel_navigator.dart';
import 'package:maid/ui/desktop/widgets/side_bar.dart';
import 'package:maid/ui/shared/widgets/chat_widgets/chat_body.dart';
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
            if (desktopNavigator.sidePanelOpen)
            const ResizableChild(
              size: ResizableSize.ratio(0.2),
              minSize: 200,
              child: SidePanelNavigator(),
            ),
            ResizableChild(
              size: desktopNavigator.sidePanelOpen ? const ResizableSize.ratio(0.8) : const ResizableSize.expand(),
              minSize: 500,
              child: const Scaffold(
                appBar: HomeAppBar(),
                body: ChatBody(),
              ),
            ),
          ]
        );
      }
    );
  }
}
