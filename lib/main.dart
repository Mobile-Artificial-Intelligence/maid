import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maid/pages/home_page.dart';

void main() {
  runApp(const MaidApp());
}

class MaidApp extends StatelessWidget {
  const MaidApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Maid',
      theme: MaidTheme().getTheme(),
      home: const MaidHomePage(title: 'Maid'),
    );
  }
}

class MaidTheme {
  ThemeData getTheme() {
    return _darkTheme;
  }

  static final ThemeData _darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey.shade800,
    colorScheme: ColorScheme.dark(
      primary: Colors.grey.shade800,
      secondary: Colors.grey.shade900,
      tertiary: Colors.blue
    ),
  );
}