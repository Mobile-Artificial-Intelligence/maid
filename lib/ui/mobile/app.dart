import 'package:flutter/material.dart';
import 'package:maid/providers/app_preferences.dart';
import 'package:maid/static/themes.dart';
import 'package:maid/ui/mobile/pages/platforms/llama_cpp_page.dart';
import 'package:maid/ui/shared/pages/about_page.dart';
import 'package:maid/ui/mobile/pages/character_browser_page.dart';
import 'package:maid/ui/shared/pages/character_customization_page.dart';
import 'package:maid/ui/mobile/pages/home_page.dart';
import 'package:maid/ui/mobile/pages/platforms/gemini_page.dart';
import 'package:maid/ui/mobile/pages/platforms/mistralai_page.dart';
import 'package:maid/ui/mobile/pages/platforms/ollama_page.dart';
import 'package:maid/ui/mobile/pages/platforms/openai_page.dart';
import 'package:maid/ui/shared/pages/settings_page.dart';
import 'package:provider/provider.dart';

class MobileApp extends StatelessWidget {
  const MobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppPreferences>(
      builder: (context, appPreferences, child) {
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
      },
    );
  }
}