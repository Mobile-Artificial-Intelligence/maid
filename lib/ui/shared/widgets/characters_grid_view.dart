import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/ui/mobile/widgets/tiles/character_browser_tile.dart';
import 'package:provider/provider.dart';

class CharactersGridView extends StatelessWidget {

  const CharactersGridView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: buildGridView
    );
  }

  Widget buildGridView(BuildContext context, AppData appData, Widget? child) {
    appData.save();
    
    return GridView.builder(
      itemCount: appData.characters.length,
      itemBuilder: (context, index) => itemBuilder(appData.characters[index]), 
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.75
      )
    );
  }

  Widget itemBuilder(Character character) {
    return Padding(
      padding: const EdgeInsets.all(
          8.0), // Adjust the padding value as needed
      child: CharacterBrowserTile(
        character: character
      ),
    );
  }
}