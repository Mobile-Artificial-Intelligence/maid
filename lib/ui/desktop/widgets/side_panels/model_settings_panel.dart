import 'package:flutter/material.dart';
import 'package:maid/enumerators/large_language_model_type.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/ui/mobile/pages/platforms/gemini_page.dart';
import 'package:maid/ui/mobile/pages/platforms/llama_cpp_page.dart';
import 'package:maid/ui/mobile/pages/platforms/mistralai_page.dart';
import 'package:maid/ui/mobile/pages/platforms/ollama_page.dart';
import 'package:maid/ui/mobile/pages/platforms/openai_page.dart';
import 'package:provider/provider.dart';

class ModelSettingsPanel extends StatelessWidget {
  const ModelSettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        switch (appData.currentSession.model.type) {
          case LargeLanguageModelType.llamacpp:
            return const LlamaCppPage();
          case LargeLanguageModelType.ollama:
            return const OllamaPage();
          case LargeLanguageModelType.openAI:
            return const OpenAiPage();
          case LargeLanguageModelType.mistralAI:
            return const MistralAiPage();
          case LargeLanguageModelType.gemini:
            return const GoogleGeminiPage();
          default:
            throw Exception('Invalid model type');
        }
      }
    );
  }
}