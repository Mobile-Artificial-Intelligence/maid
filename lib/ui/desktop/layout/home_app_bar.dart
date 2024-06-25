import 'package:flutter/material.dart';
import 'package:maid/classes/providers/large_language_models/llama_cpp_model.dart';
import 'package:maid/enumerators/large_language_model_type.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:maid/ui/desktop/buttons/huggingface_button.dart';
import 'package:maid/ui/desktop/buttons/load_model_button.dart';
import 'package:maid/ui/desktop/dropdowns/model_dropdown.dart';
import 'package:maid/ui/shared/dropdowns/llm_platform_dropdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

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
      child: buildRow()
    );
  }

  Widget buildRow() {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        final model = appData.currentSession.model;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const LlmPlatformDropdown(),
            const Spacer(flex: 1),
            if (model.type == LargeLanguageModelType.llamacpp)
            ...llamaCppWidgets(context)
            else
            const Expanded(
              flex: 8,
              child: ModelDropdown(),
            ),
            const Spacer(flex: 1),
            IconButton(
              tooltip: 'About',
              icon: const Icon(Icons.info), 
              onPressed: () => openAbout(context)
            ),
          ],
        );
      }
    );
  }

  List<Widget> llamaCppWidgets(BuildContext context) {
    return [
      const HuggingfaceButton(),
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
      )
    ];
  }

  void openAbout(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/about'
    );
  }
}