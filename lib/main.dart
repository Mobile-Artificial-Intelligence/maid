import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maid/providers/user.dart';
import 'package:maid/ui/mobile/pages/home_page.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/static/themes.dart';
import 'package:provider/provider.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows) {
    Llama.libraryPath = 'bin/llama.dll';
  } else if (Platform.isLinux || Platform.isAndroid) {
    Llama.libraryPath = 'libllama.so';
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MainProvider()),
        ChangeNotifierProvider(create: (context) => AiPlatform()),
        ChangeNotifierProvider(create: (context) => User()),
        ChangeNotifierProvider(create: (context) => Character()),
        ChangeNotifierProvider(create: (context) => Session()),
      ],
      child: const MaidApp(),
    ),
  );
}

class MainProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _initialised = false;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  bool get initialised => _initialised;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void init() {
    _initialised = true;
  }

  void reset() {
    _initialised = false;
    notifyListeners();
  }
}

class MaidApp extends StatefulWidget {
  const MaidApp({super.key});

  @override
  MaidAppState createState() => MaidAppState();
}

class MaidAppState extends State<MaidApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer5<MainProvider, AiPlatform, User, Character, Session>(
      builder: (context, mainProvider, ai, user, character, session, child) {
        if (!mainProvider.initialised) {
          mainProvider.init();
          ai.init();
          user.init();
          character.init();
          session.init();
        }

        return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Maid',
            theme: Themes.lightTheme(),
            darkTheme: Themes.darkTheme(),
            themeMode: mainProvider.themeMode,
            home: const HomePage(title: "Maid"));
      },
    );
  }
}
