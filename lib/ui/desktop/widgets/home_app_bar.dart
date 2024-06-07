import 'package:flutter/material.dart';
import 'package:maid/classes/large_language_model.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/ui/mobile/widgets/dropdowns/llm_dropdown.dart';
import 'package:provider/provider.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      elevation: 0.0,
      actions: [
        const SizedBox(width: 20),
        const LlmDropdown(),
        const Expanded(child: SizedBox()),
        FilledButton(
          onPressed: () {
            switch (context.read<Session>().model.type) {
              case LargeLanguageModelType.llamacpp:
                Navigator.pushNamed(context, '/llamacpp');
              case LargeLanguageModelType.ollama:
                Navigator.pushNamed(context, '/ollama');
              case LargeLanguageModelType.openAI:
                Navigator.pushNamed(context, '/openai');
              case LargeLanguageModelType.mistralAI:
                Navigator.pushNamed(context, '/mistralai');
              case LargeLanguageModelType.gemini:
                Navigator.pushNamed(context, '/gemini');
              default:
                throw Exception('Invalid model type');
            }
          }, 
          child: const Text(
            "Model Settings"
          )
        ),
        const SizedBox(width: 10),
        FilledButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/settings'
            );
          }, 
          child: const Text(
            "App Settings"
          )
        ),
        const SizedBox(width: 10),
        FilledButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/about'
            );
          }, 
          child: const Text(
            "About"
          )
        ),
        const SizedBox(width: 10)
      ],
    );
  }
}
