import 'package:flutter/material.dart';
import 'package:maid/ui/desktop/buttons/new_character_button.dart';
import 'package:maid/ui/shared/utilities/session_busy_overlay.dart';
import 'package:maid/ui/shared/views/characters_grid_view.dart';

class CharactersPanel extends StatelessWidget {
  const CharactersPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const NewCharacterButton(),
        centerTitle: true,
      ),
      body: const SessionBusyOverlay(
        child: CharactersGridView(),
      )
    );
  }
}
