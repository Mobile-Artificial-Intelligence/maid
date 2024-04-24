import 'package:flutter/material.dart';
import 'package:maid/classes/large_language_model.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/ui/mobile/pages/about_page.dart';
import 'package:maid/ui/mobile/pages/platforms/gemini_page.dart';
import 'package:maid/ui/mobile/pages/settings_page.dart';
import 'package:provider/provider.dart';
import 'package:maid/ui/mobile/pages/platforms/llama_cpp_page.dart';
import 'package:maid/ui/mobile/pages/platforms/mistralai_page.dart';
import 'package:maid/ui/mobile/pages/platforms/ollama_page.dart';
import 'package:maid/ui/mobile/pages/platforms/openai_page.dart';
import 'package:maid/ui/mobile/widgets/dropdowns/llm_dropdown.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}

class _HomeAppBarState extends State<HomeAppBar> {
  final iconButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      elevation: 0.0,
      actions: [
        const SizedBox(width: 34),
        const LlmDropdown(),
        const Expanded(child: SizedBox()),
        IconButton(
          key: iconButtonKey, // Assign the GlobalKey to your IconButton
          icon: const Icon(
            Icons.account_tree_rounded,
            size: 24,
          ),
          onPressed: onPressed,
        )
      ],
    );
  }

  void onPressed() {
    final RenderBox renderBox = iconButtonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    final Session session = context.read<Session>();

    session.model.updateOptions();

    List<String> options = session.model.options;

    List<PopupMenuEntry<dynamic>> modelOptions = options.map((String modelName) => PopupMenuItem(
      padding: EdgeInsets.zero,
      child: Consumer<Session>(
        builder: 
          (context, session, child) {
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
              title: Text(modelName),
              onTap: () {
                session.model.name = modelName;
              },
              tileColor: session.model.name == modelName ? Theme.of(context).colorScheme.secondary : null,
            );
          }
    )))
    .toList();
    
    showMenu(
      context: context,
      // Calculate the position based on the button's position and size
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx,
        offset.dy,
      ),
      items: [
        ...modelOptions,
        if (modelOptions.isNotEmpty)
          const PopupMenuDivider(
            height: 10,
          ),
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
            title: const Text('LLM Parameters'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  switch (context.read<Session>().model.type) {
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
                      return const LlamaCppPage();
                  }
                }),
              );
            },
          ),
        ),
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
            title: const Text('App Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsPage()));
            },
          ),
        ),
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context); // Close the menu first
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AboutPage()));
            },
          ),
        ),
      ],
    );
  }
}
