import 'package:flutter/material.dart';
import 'package:maid/classes/providers/artificial_intelligence.dart';
import 'package:maid/enumerators/large_language_model_type.dart';
import 'package:maid/ui/shared/shaders/blade_runner_gradient_shader.dart';
import 'package:provider/provider.dart';

class LlmPlatformDropdown extends StatefulWidget {
  const LlmPlatformDropdown({super.key});

  @override
  State<LlmPlatformDropdown> createState() => _LlmPlatformDropdownState();
}

class _LlmPlatformDropdownState extends State<LlmPlatformDropdown> {
  bool open = false;

  @override
  Widget build(BuildContext context) {
    return BladeRunnerGradientShader(
      stops: const [0.25, 0.75],
      child: dropdownBuilder()
    );
  }

  Widget dropdownBuilder() {
    return Consumer<ArtificialIntelligence>(
      builder: (context, ai, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ai.llm.type.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold
              )
            )
            // ,
            // PopupMenuButton(
            //   tooltip: 'Select Large Language Model API',
            //   icon: Icon(
            //     open ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            //     color: Colors.white,
            //     size: 24,
            //   ),
            //   offset: const Offset(0, 40),
            //   itemBuilder: itemBuilder,
            //   onOpened: () => setState(() => open = true),
            //   onCanceled: () => setState(() => open = false),
            //   onSelected: (_) => setState(() => open = false)
            // )
          ]
        );
      }
    );
  }

  List<PopupMenuEntry<dynamic>> itemBuilder(BuildContext context) {
    return [
      PopupMenuItem(
        padding: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          title: const Text('LlamaCPP'),
          onTap: () => ArtificialIntelligence.of(context).switchLargeLanguageModel(LargeLanguageModelType.llamacpp),
        ),
      ),
      PopupMenuItem(
        padding: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          title: const Text('OpenAI'),
          onTap: () => ArtificialIntelligence.of(context).switchLargeLanguageModel(LargeLanguageModelType.openAI),
        ),
      ),
      PopupMenuItem(
        padding: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          title: const Text('Ollama'),
          onTap: () => ArtificialIntelligence.of(context).switchLargeLanguageModel(LargeLanguageModelType.ollama),
        ),
      ),
      PopupMenuItem(
        padding: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          title: const Text('MistralAI'),
          onTap: () => ArtificialIntelligence.of(context).switchLargeLanguageModel(LargeLanguageModelType.mistralAI),
        ),
      ),
      PopupMenuItem(
        padding: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          title: const Text('Gemini'),
          onTap: () => ArtificialIntelligence.of(context).switchLargeLanguageModel(LargeLanguageModelType.gemini),
        ),
      )
    ];
  }
}
