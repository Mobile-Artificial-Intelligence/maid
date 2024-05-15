import 'package:flutter/material.dart';
import 'package:maid/ui/mobile/widgets/appbars/generic_app_bar.dart';

// This page is to mock the LlamaCPP page, which is not available on the web platform
class LlamaCppPage extends StatelessWidget {
  const LlamaCppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: GenericAppBar(title: "Here there be dragons..."),
      body: Center(
        child: Text(
          "How did you get here?",
        ),
      ),
    );
  }
}