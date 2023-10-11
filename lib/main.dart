import 'package:flutter/material.dart';
import 'package:maid/theme.dart';
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