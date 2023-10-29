import 'package:flutter/material.dart';
import 'package:maid/config/theme.dart';
import 'package:maid/pages/home_page.dart';

final maidAppKey = GlobalKey<_MaidAppState>();

void main() {
  runApp(MaidApp(key: maidAppKey));
}

class MaidApp extends StatefulWidget {
  const MaidApp({super.key});

  @override
  _MaidAppState createState() => _MaidAppState();
}

class _MaidAppState extends State<MaidApp> {
  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  _loadTheme() async {
    await MaidTheme.loadThemePreference();
    setState(() {});
  }

  void refreshApp() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Maid',
      theme: MaidTheme.theme,
      home: const MaidHomePage(title: 'Maid'),
    );
  }
}