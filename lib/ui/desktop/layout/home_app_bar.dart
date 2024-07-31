import 'package:flutter/material.dart';
import 'package:maid/enumerators/large_language_model_type.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:maid/ui/desktop/dropdowns/remote_model_dropdown.dart';
import 'package:maid/ui/shared/buttons/new_session_button.dart';
import 'package:maid/ui/shared/dropdowns/llm_platform_dropdown.dart';
import 'package:maid/ui/shared/groups/llama_cpp_model_controls.dart';
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
            Expanded(
              flex: 8,
              child: model.type == LargeLanguageModelType.llamacpp ? 
                const LlamaCppModelControls() : 
                const RemoteModelDropdown(),
            ),
            const Spacer(flex: 1),
            const NewSessionButton(),
            const SizedBox(width: 8.0),
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

  void openAbout(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/about'
    );
  }
}