import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/ui/mobile/widgets/session_busy_overlay.dart';
import 'package:maid/ui/shared/widgets/characters_grid_view.dart';
import 'package:provider/provider.dart';

class CharactersPanel extends StatelessWidget {
  const CharactersPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppData, Character>(
      builder: pageBuilder
    );
  }

  Widget pageBuilder(BuildContext context, AppData appData, Character character, Widget? child) {
    appData.save();
    
    return Scaffold(
      appBar: AppBar(
        title: FilledButton(
          onPressed: () {
            final newCharacter = Character();
            appData.addCharacter(newCharacter);
            character.from(newCharacter);
          },
          child: const Text(
            "New Character"
          )
        ),
        centerTitle: true,
      ),
      body: const SessionBusyOverlay(
        child: CharactersGridView(),
      )
    );
  }
}
