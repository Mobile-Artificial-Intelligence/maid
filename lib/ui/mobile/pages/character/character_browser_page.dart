import 'package:flutter/material.dart';
import 'package:maid/ui/mobile/widgets/appbars/generic_app_bar.dart';

class CharacterBrowserPage extends StatefulWidget {
  const CharacterBrowserPage({super.key});

  @override
  State<CharacterBrowserPage> createState() => _CharacterBrowserPageState();
}

class _CharacterBrowserPageState extends State<CharacterBrowserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GenericAppBar(title: "Character Browser"),
      body: Placeholder(),
    );
  }
}