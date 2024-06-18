import 'package:flutter/material.dart';
import 'package:maid/enumerators/large_language_model_type.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/ui/desktop/widgets/side_panels/model_settings/google_gemini_panel.dart';
import 'package:maid/ui/desktop/widgets/side_panels/model_settings/llama_cpp_panel.dart';
import 'package:maid/ui/desktop/widgets/side_panels/model_settings/mistral_ai_panel.dart';
import 'package:maid/ui/mobile/pages/model_settings/ollama_page.dart';
import 'package:maid/ui/mobile/pages/model_settings/open_ai_page.dart';
import 'package:provider/provider.dart';

class ModelSettingsPanel extends StatelessWidget {
  const ModelSettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        switch (appData.currentSession.model.type) {
          case LargeLanguageModelType.llamacpp:
            return const LlamaCppPanel();
          case LargeLanguageModelType.ollama:
            return const OllamaPage();
          case LargeLanguageModelType.openAI:
            return const OpenAiPage();
          case LargeLanguageModelType.mistralAI:
            return const MistralAiPanel();
          case LargeLanguageModelType.gemini:
            return const GoogleGeminiPanel();
          default:
            throw Exception('Invalid model type');
        }
      }
    );
  }
}