// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maid/ModelFilePath.dart';
import 'package:maid/lib.dart';
import 'package:system_info_plus/system_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
      // ThemeData(
      //   colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple)
      //       .copyWith(background: Colors.grey.shade800)),
      home: const MyHomePage(title: 'Maid'),
    );
  }
}

class MaidTheme {
  static Color gradientColorA = const Color(0xFFFFFFFF);
  static Color gradientColorB = const Color(0xFF000000);

  ThemeData getTheme() {
    gradientColorA = const Color(0xFF000000);
    gradientColorB = const Color(0xFFFFFFFF);
    return _darkTheme;
  }

  static final ThemeData _darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey[700],
    colorScheme: ColorScheme.dark(
      primary: Colors.cyan.shade700,
      secondary: Colors.purple.shade900,
    ),
  );
}

