import 'package:flutter/material.dart';
import 'package:maid/static/generation_manager.dart';
import 'package:maid/widgets/chat_widgets/chat_ui.dart';
import 'package:maid/widgets/settings_widgets/double_button_row.dart';

class DesktopHomePage extends StatefulWidget {
  final String title;

  const DesktopHomePage({super.key, required this.title});

  @override
  DesktopHomePageState createState() => DesktopHomePageState();
}

class DesktopHomePageState extends State<DesktopHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
          ),
        ),
        title: DoubleButtonRow(
          leftText: "Local",
          leftOnPressed: () {
            setState(() {
              GenerationManager.remote = false;
            });
          },
          rightText: "Remote",
          rightOnPressed: () {
            setState(() {
              GenerationManager.remote = true;
            });
          },
        ),
      ),
      body: const ChatUI(),
    );
  }
}