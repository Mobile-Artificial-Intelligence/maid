import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maid/providers/model.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/static/themes.dart';
import 'package:provider/provider.dart';
import 'package:maid/pages/desktop_home.dart';
import 'package:maid/pages/mobile_home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MainProvider()),
        ChangeNotifierProvider(create: (context) => Model()),
        ChangeNotifierProvider(create: (context) => Character()),
        ChangeNotifierProvider(create: (context) => Session()),
      ],
      child: const MaidApp(),
    ),
  );
}

class MainProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
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
  void initState() {
    super.initState();
    context.read<Model>().init();
    context.read<Character>().init();
    context.read<Session>().init();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final aspectRatio = screenSize.width / screenSize.height;

    final Widget homePage;
    if (aspectRatio > 0.9) {
      homePage = const DesktopHomePage(title: 'Maid');
    } else {
      homePage = const MobileHomePage(title: 'Maid');
    }

    return Consumer<MainProvider>(
      builder: (context, mainProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Maid',
          theme: Themes.lightTheme(),
          darkTheme: Themes.darkTheme(),
          themeMode: mainProvider.themeMode,
          home: homePage
        );
      },
    );
  }
}
