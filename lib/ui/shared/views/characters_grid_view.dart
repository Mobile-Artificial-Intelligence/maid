import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_data.dart';
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
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.75
      ),
      itemBuilder: buildCharacterTile, 
    );
  }

  Widget buildCharacterTile(BuildContext context, int index) {
    return CharacterTile(
      character: AppData.of(context).characters[index],
      isSelected: AppData.of(context).currentCharacter == AppData.of(context).characters[index],
    );
  }
}