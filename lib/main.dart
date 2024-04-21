import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/providers/user.dart';
import 'package:maid/ui/mobile/pages/home_page.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/static/themes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  String? lastUserString = prefs.getString("last_user");
  Map<String, dynamic> lastUser = json.decode(lastUserString ?? "{}");
  User user = User.fromMap(lastUser);

  String? lastCharacterString = prefs.getString("last_character");
  Map<String, dynamic> lastCharacter = json.decode(lastCharacterString ?? "{}");
  Character character = Character.fromMap(lastCharacter);

  String? lastSessionString = prefs.getString("last_session");
  Map<String, dynamic> lastSession = json.decode(lastSessionString ?? "{}");
  Session session = Session.fromMap(lastSession);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MainProvider()),
        ChangeNotifierProvider(create: (context) => user),
        ChangeNotifierProvider(create: (context) => character),
        ChangeNotifierProvider(create: (context) => session),
      ],
      child: const MaidApp(),
    ),
  );
}

class MainProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  set themeMode(ThemeMode value) {
    _themeMode = value;
    notifyListeners();
  }

  void reset() {
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
    return Consumer<MainProvider>(
      builder: (context, mainProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Maid',
          theme: Themes.lightTheme(),
          darkTheme: Themes.darkTheme(),
          themeMode: mainProvider.themeMode,
          home: const HomePage(title: "Maid")
        );
      },
    );
  }
}
