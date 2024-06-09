import 'package:flutter/material.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:maid/ui/desktop/widgets/appbars/home_app_bar.dart';
import 'package:maid/ui/shared/chat_widgets/chat_body.dart';

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
        ResizableChild(
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
        const ResizableChild(
          size: ResizableSize.ratio(0.8),
          minSize: 500,
          child: Scaffold(
            appBar: HomeAppBar(),
            body: ChatBody(),
          ),
        ),
      ]
    );
  }
}
