import 'package:flutter/material.dart';
import 'package:maid/providers/app_preferences.dart';
import 'package:maid/providers/user.dart';
import 'package:maid/ui/desktop/pages/home_page.dart';
import 'package:maid/ui/mobile/pages/about_page.dart';
import 'package:maid/ui/mobile/pages/character/character_browser_page.dart';
import 'package:maid/ui/mobile/pages/character/character_customization_page.dart';
import 'package:maid/ui/mobile/pages/home_page.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/static/themes.dart';
import 'package:maid/ui/mobile/pages/platforms/llama_cpp_page.dart'
if (dart.library.html) 'package:maid/mocks/mock_llama_cpp_page.dart';
import 'package:maid/ui/mobile/pages/platforms/gemini_page.dart';
import 'package:maid/ui/mobile/pages/platforms/mistralai_page.dart';
import 'package:maid/ui/mobile/pages/platforms/ollama_page.dart';
import 'package:maid/ui/mobile/pages/platforms/openai_page.dart';
import 'package:maid/ui/mobile/pages/settings_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppPreferences appPreferences = await AppPreferences.last;
  User user = await User.last;
  Character character = await Character.last;
  Session session = await Session.last;

  runApp(
    MaidApp(user: user, character: character, session: session, appPreferences: appPreferences)
  );
}

class MaidApp extends StatelessWidget {
  final AppPreferences appPreferences;
  final User user;
  final Character character;
  final Session session;

  const MaidApp({super.key, required this.user, required this.character, required this.session, required this.appPreferences});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => appPreferences),
        ChangeNotifierProvider(create: (context) => user),
        ChangeNotifierProvider(create: (context) => character),
        ChangeNotifierProvider(create: (context) => session),
      ],
      child: Consumer<AppPreferences>(
        builder: appBuilder
      ),
    );
  }

  Widget appBuilder(BuildContext context, AppPreferences appPreferences, Widget? child) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Maid',
      theme: Themes.lightTheme(),
      darkTheme: Themes.darkTheme(),
      themeMode: appPreferences.themeMode,
      home: const DesktopHomePage()
    );
  }

  Widget mobileApp(AppPreferences appPreferences) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Maid',
      theme: Themes.lightTheme(),
      darkTheme: Themes.darkTheme(),
      themeMode: appPreferences.themeMode,
      initialRoute: '/',
      routes: {
        '/character': (context) => const CharacterCustomizationPage(),
        '/characters': (context) => const CharacterBrowserPage(),
        '/llamacpp': (context) => const LlamaCppPage(),
        '/ollama': (context) => const OllamaPage(),
        '/openai': (context) => const OpenAiPage(),
        '/mistralai': (context) => const MistralAiPage(),
        '/gemini': (context) => const GoogleGeminiPage(),
        '/settings': (context) => const SettingsPage(),
        '/about': (context) => const AboutPage(),
      },
      home: const MobileHomePage()
    );
  }
}
