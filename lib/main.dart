import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maid/static/memory_manager.dart';
import 'package:maid/static/theme.dart';
import 'package:maid/pages/home_page.dart';

final maidAppKey = GlobalKey<MaidAppState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MemoryManager.init();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark),
  );
  runApp(MaidApp(key: maidAppKey));
}

class MaidApp extends StatefulWidget {
  const MaidApp({super.key});

  @override
  MaidAppState createState() => MaidAppState();
}

class MaidAppState extends State<MaidApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTheme();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      MemoryManager.saveAll();
    }
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
