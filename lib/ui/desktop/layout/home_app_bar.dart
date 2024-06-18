import 'package:flutter/material.dart';
import 'package:maid/classes/llama_cpp_model.dart';
import 'package:maid/ui/desktop/buttons/load_model_button.dart';
import 'package:maid/ui/shared/dropdowns/llm_platform_dropdown.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      height: preferredSize.height,
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const LlmPlatformDropdown(),
          const Spacer(flex: 1),
          IconButton(
            tooltip: 'HuggingFace',
            onPressed: () {}, 
            icon: SizedBox(
              width: 30.0,
              height: 30.0,
              child: SvgPicture.asset(
                'assets/huggingface-colour.svg',
              ),
            )
          ),
          const Expanded(
            flex: 8,
            child: LoadModelButton(),
          ),
          IconButton(
            tooltip: "Eject Model",
            onPressed: () {
              LlamaCppModel.of(context).resetUri();
              LlamaCppModel.of(context).name = "";
            },
            icon: const Icon(Icons.eject_rounded),
          ),
          const Spacer(flex: 1),
          IconButton(
            tooltip: 'About',
            icon: const Icon(Icons.info), 
            onPressed: () => openAbout(context)
          ),
        ],
      ),
    );
  }

  void openAbout(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/about'
    );
  }
}