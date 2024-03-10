import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:maid/ui/mobile/pages/platforms/llama_cpp_page.dart';
import 'package:maid/ui/mobile/pages/platforms/mistralai_page.dart';
import 'package:maid/ui/mobile/pages/platforms/ollama_page.dart';
import 'package:maid/ui/mobile/pages/platforms/openai_page.dart';
import 'package:maid/ui/mobile/widgets/dropdowns/api_dropdown.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}

class _HomeAppBarState extends State<HomeAppBar> {
  final GlobalKey _menuKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      actions: [
        const SizedBox(width: 34),
        const ApiDropdown(),
        const Expanded(child: SizedBox()),
        IconButton(
          key: _menuKey, // Assign the GlobalKey to your IconButton
          icon: const Icon(Icons.account_tree_rounded),
          onPressed: onPressed,
        )
      ],
    );
  }

  void onPressed() {
    final RenderBox renderBox = _menuKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

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
        PopupMenuItem(
          child: ListTile(
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
      ],
    );
  }
}
