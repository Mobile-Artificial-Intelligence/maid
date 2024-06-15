import 'package:flutter/material.dart';
import 'package:maid/ui/desktop/widgets/buttons/new_character_button.dart';
import 'package:maid/ui/mobile/widgets/session_busy_overlay.dart';
import 'package:maid/ui/shared/widgets/characters_grid_view.dart';

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
