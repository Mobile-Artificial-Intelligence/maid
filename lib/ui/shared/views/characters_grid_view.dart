import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/ui/shared/tiles/character_tile.dart';
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
      itemBuilder: (context, index) => CharacterTile(
        character: appData.characters[index],
        isSelected: appData.currentCharacter == appData.characters[index],
      ), 
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.75
      )
    );
  }
}