import 'package:flutter/material.dart';
import 'package:maid/theme.dart';
import 'package:maid/pages/home_page.dart';

void main() {
  runApp(MaidApp());
}

class MaidApp extends StatefulWidget {
  @override
  _MaidAppState createState() => _MaidAppState();
}

class _MaidAppState extends State<MaidApp> {
  late ThemeData _currentTheme;

  @override
  void initState() {
    super.initState();
    _currentTheme = MaidTheme.darkTheme; // Starting with dark theme
  }

  void _toggleTheme() {
    setState(() {
      if (_currentTheme == MaidTheme.darkTheme) {
        _currentTheme = MaidTheme.lightTheme;
      } else {
        _currentTheme = MaidTheme.darkTheme;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Maid',
      theme: _currentTheme,
      home: MaidHomePage(
        title: 'Maid',
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}