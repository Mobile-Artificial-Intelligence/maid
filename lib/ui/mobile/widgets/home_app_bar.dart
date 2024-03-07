import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:maid/ui/mobile/pages/platforms/llama_cpp_page.dart';
import 'package:maid/ui/mobile/pages/platforms/mistralai_page.dart';
import 'package:maid/ui/mobile/pages/platforms/ollama_page.dart';
import 'package:maid/ui/mobile/pages/platforms/openai_page.dart';
import 'package:maid/ui/mobile/widgets/dropdowns/api_dropdown.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(elevation: 0.0, titleSpacing: 0.0, actions: [
      const SizedBox(width: 34),
      const ApiDropdown(),
      const Expanded(child: SizedBox()),
      IconButton(
        icon: const Icon(Icons.account_tree_rounded),
        onPressed: () {
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
    ]);
  }

  // Mirrors the AppBar's preferredSize getter
  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}
