import 'package:flutter/material.dart';
import 'package:maid/ui/desktop/widgets/appbars/home_app_bar.dart';

class DesktopHomePage extends StatefulWidget {
  const DesktopHomePage({super.key});

  @override
  State<DesktopHomePage> createState() => _DesktopHomePageState();
}

class _DesktopHomePageState extends State<DesktopHomePage> {
  @override
  Widget build(BuildContext context) {
    return Row(
        children: [
          Container(
            width: 300,
            color: Colors.blue,
            child: const Column(
              children: [
                // Add your side panel content here
                Text(
                  'Side Panel',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
                // Add more widgets as needed
              ],
            ),
          ),
          const Expanded(
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
        ],
      );
  }
}
