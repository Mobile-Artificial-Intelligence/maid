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
import 'package:your_app/services/app_settings_service.dart';
import 'package:your_app/models/model_provider.dart';
import 'package:your_app/models/character_provider.dart';

/// The [MobileApp] class represents the main application widget for the mobile platforms.
/// It is a stateful widget that builds the user interface based on the consumed [AppPreferences].
class MobileApp extends StatefulWidget {
  const MobileApp({super.key});

  @override
  State<MobileApp> createState() => _MobileAppState();
}

class _MobileAppState extends State<MobileApp> {
  final AppSettingsService _settings = AppSettingsService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllSettings();
  }

  Future<void> _loadAllSettings() async {
    try {
      // Load model settings
      final modelSettings = _settings.getModelSettings();
      final characterId = _settings.getSelectedCharacter();

      if (mounted) {
        // Apply model settings
        if (modelSettings != null) {
          final modelProvider = context.read<ModelProvider>();
          await modelProvider.setModel(modelSettings.modelId);
          modelProvider.updateParameters(
            temperature: modelSettings.temperature,
            maxTokens: modelSettings.maxTokens,
            topP: modelSettings.topP,
            topK: modelSettings.topK,
            contextLength: modelSettings.contextLength,
          );
        }

        // Apply character settings
        if (characterId != null) {
          await context.read<CharacterProvider>().selectCharacter(characterId);
        }
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppPreferences>(
      builder: (context, appPreferences, child) {
        if (_isLoading) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        
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