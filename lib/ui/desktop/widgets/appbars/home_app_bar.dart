import 'package:flutter/material.dart';
import 'package:maid/classes/large_language_model.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/ui/shared/llm_dropdown.dart';
import 'package:provider/provider.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      height: preferredSize.height,
      color: Theme.of(context).colorScheme.background,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const LlmDropdown(),
          trailingWidgets(context)
        ],
      ),
    );
  }

  Widget trailingWidgets(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Model Settings',
          icon: const Icon(Icons.account_tree_rounded), 
          onPressed: () => openModelSettings(context)
        ),
        IconButton(
          tooltip: 'App Settings',
          icon: const Icon(Icons.settings), 
          onPressed: () => openAppSettings(context)
        ),
        IconButton(
          tooltip: 'About',
          icon: const Icon(Icons.info), 
          onPressed: () => openAbout(context)
        ),
      ],
    );
  }

  void openModelSettings(BuildContext context) {
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
  }

  void openAppSettings(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/settings'
    );
  }

  void openAbout(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/about'
    );
  }
}