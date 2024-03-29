import 'package:flutter/material.dart';
import 'package:maid/ui/mobile/pages/about_page.dart';
import 'package:maid/ui/mobile/pages/settings_page.dart';
import 'package:provider/provider.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:maid/ui/mobile/pages/platforms/llama_cpp_page.dart';
import 'package:maid/ui/mobile/pages/platforms/mistralai_page.dart';
import 'package:maid/ui/mobile/pages/platforms/ollama_page.dart';
import 'package:maid/ui/mobile/pages/platforms/openai_page.dart';
import 'package:maid/ui/mobile/widgets/dropdowns/ai_platform_dropdown.dart';

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
      elevation: 0.0,
      actions: [
        const SizedBox(width: 34),
        const AiPlatformDropdown(),
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

    context.read<AiPlatform>().getOptions().then((options) {
      List<PopupMenuEntry<dynamic>> modelOptions = options
        .map((String modelName) => PopupMenuItem(
          padding: EdgeInsets.zero,
          child: Consumer<AiPlatform>(
            builder: 
              (context, ai, child) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                  title: Text(modelName),
                  onTap: () {
                    ai.model = modelName;
                  },
                  tileColor: ai.model == modelName ? Theme.of(context).colorScheme.secondary : null,
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
                      switch (context.read<AiPlatform>().apiType) {
                        case AiPlatformType.llamacpp:
                          return const LlamaCppPage();
                        case AiPlatformType.ollama:
                          return const OllamaPage();
                        case AiPlatformType.openAI:
                          return const OpenAiPage();
                        case AiPlatformType.mistralAI:
                          return const MistralAiPage();
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
    });
  }
}
