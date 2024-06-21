import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:maid/ui/shared/utilities/session_busy_overlay.dart';
import 'package:maid/ui/shared/views/characters_grid_view.dart';

class CharacterBrowserPage extends StatelessWidget {
  const CharacterBrowserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text("Character Browser"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              AppData.of(context).newCharacter();
            },
          ),
        ],
      ),
      body: const SessionBusyOverlay(
        child: CharactersGridView(),
      )
    );
  }
}
