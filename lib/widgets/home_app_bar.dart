import 'package:flutter/material.dart';
import 'package:maid/static/generation_manager.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  HomeAppBarState createState() => HomeAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(50);
}

class HomeAppBarState extends State<HomeAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
        ),
      ),
      title: SegmentedButton<bool>(
        segments: const [
          ButtonSegment(
            label: Text("Local"),
            value: false
          ),
          ButtonSegment(
            label: Text("Remote"),
            value: true
          ),
        ],
        selected: <bool>{GenerationManager.remote},
        onSelectionChanged: (value) {
          setState(() {
            GenerationManager.remote = value.first;
          });
        },
        showSelectedIcon: false,
      ),
    );
  }
}