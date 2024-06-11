import 'package:flutter/material.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:maid/providers/desktop_layout.dart';
import 'package:maid/ui/desktop/widgets/appbars/home_app_bar.dart';
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
        Container(
          color: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 10),
          width: 50,
          child: Column(
            children: [
              IconButton(
                icon: const Icon(Icons.view_sidebar_rounded),
                onPressed: () {
                  context.read<DesktopLayout>().toggleSidePanel();
                },
              ),
            ],
          ),
        ),
        Expanded(child: buildResizableContainer(context))
      ]
    );
  }

  Widget buildResizableContainer(BuildContext context) {
    return Consumer<DesktopLayout>(
      builder: (context, desktopLayout, child) {
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
            if (desktopLayout.sidePanelOpen)
            ResizableChild(
              size: const ResizableSize.ratio(0.2),
              minSize: 200,
              child: Container(
                color: Theme.of(context).colorScheme.background,
                child: const Center(
                  child: Text(
                    'Side Panel',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ),
            ResizableChild(
              size: desktopLayout.sidePanelOpen ? const ResizableSize.ratio(0.8) : const ResizableSize.expand(),
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
