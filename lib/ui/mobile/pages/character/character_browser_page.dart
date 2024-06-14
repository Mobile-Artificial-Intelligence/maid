import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/ui/mobile/widgets/session_busy_overlay.dart';
import 'package:maid/ui/mobile/widgets/tiles/character_browser_tile.dart';
import 'package:provider/provider.dart';

class CharacterBrowserPage extends StatelessWidget {
  const CharacterBrowserPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Consumer2<AppData, Character>(
      builder: pageBuilder
    );
  }

  Widget pageBuilder(BuildContext context, AppData appData, Character character, Widget? child) {
    appData.currentCharacter = character;
    appData.save();
    
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
              final newCharacter = Character();
              appData.currentCharacter = newCharacter;
              character.from(newCharacter);
            },
          ),
        ],
      ),
      body: SessionBusyOverlay(
        child: GridView.builder(
          itemCount: appData.characters.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(
                  8.0), // Adjust the padding value as needed
              child: CharacterBrowserTile(
                character: appData.characters[index]
              ),
            );
          }, 
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 0.75
          )
        )
      )
    );
  }
}
