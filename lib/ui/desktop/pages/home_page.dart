import 'package:flutter/material.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:maid/ui/desktop/widgets/appbars/home_app_bar.dart';

class DesktopHomePage extends StatefulWidget {
  const DesktopHomePage({super.key});

  @override
  State<DesktopHomePage> createState() => _DesktopHomePageState();
}

class _DesktopHomePageState extends State<DesktopHomePage> {
  @override
  Widget build(BuildContext context) {
    return ResizableContainer(
      direction: Axis.horizontal,
      children: [
        ResizableChild(
          minSize: 200,
          child: Container(
            color: Colors.blue,
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
            body: Center(
              child: Text(
                'Desktop Home Page',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ),
      ]
    );
  }
}
