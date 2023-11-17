import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maid/static/memory_manager.dart';
import 'package:maid/static/theme.dart';
import 'package:maid/pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MemoryManager.init();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark
    ),
  );
  runApp(const MaidApp());
}

class MaidApp extends StatefulWidget {
  const MaidApp({super.key});

  @override
  MaidAppState createState() => MaidAppState();
}

class MaidAppState extends State<MaidApp> {
  @override
  void initState() {
    super.initState();
    MaidTheme.registerCallback(refreshApp);
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
