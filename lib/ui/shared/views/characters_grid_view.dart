import 'package:flutter/material.dart';
import 'package:maid/classes/providers/characters.dart';
import 'package:maid/ui/shared/tiles/character_tile.dart';
import 'package:provider/provider.dart';

class CharactersGridView extends StatelessWidget {

  const CharactersGridView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CharacterCollection>(
      builder: buildGridView
    );
  }

  Widget buildGridView(BuildContext context, CharacterCollection characters, Widget? child) {
    characters.save();

    return GridView.builder(
      itemCount: characters.list.length,
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
      character: CharacterCollection.of(context).list[index],
      isSelected: CharacterCollection.of(context).current == CharacterCollection.of(context).list[index],
    );
  }
}