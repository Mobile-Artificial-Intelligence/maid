import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_preferences.dart';
import 'package:maid/classes/static/themes.dart';
import 'package:maid/ui/mobile/pages/model_settings/llama_cpp_page.dart';
import 'package:maid/ui/shared/pages/about_page.dart';
import 'package:maid/ui/mobile/pages/character_browser_page.dart';
import 'package:maid/ui/shared/pages/character_customization_page.dart';
import 'package:maid/ui/mobile/pages/home_page.dart';
import 'package:maid/ui/mobile/pages/model_settings/google_gemini_page.dart';
import 'package:maid/ui/mobile/pages/model_settings/mistral_ai_page.dart';
import 'package:maid/ui/mobile/pages/model_settings/ollama_page.dart';
import 'package:maid/ui/mobile/pages/model_settings/open_ai_page.dart';
import 'package:maid/ui/mobile/pages/settings_page.dart';
import 'package:provider/provider.dart';

/// The [MobileApp] class represents the main application widget for the mobile platforms.
/// It is a stateless widget that builds the user interface based on the consumed [AppPreferences].
class MobileApp extends StatelessWidget {
  const MobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppPreferences>(
      builder: appBuilder
    );
  }

  /// Builds the root widget for the Maid mobile app.
  ///
  /// This function takes in the [context], [appPreferences], and [child] parameters
  /// and returns a [MaterialApp] widget that serves as the root of the app.
  /// The [MaterialApp] widget is configured with various properties such as the app title,
  /// theme, initial route, and route mappings.
  /// The [home] property is set to [MobileHomePage], which serves as the default landing page.
  Widget appBuilder(BuildContext context, AppPreferences appPreferences, Widget? child) {
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