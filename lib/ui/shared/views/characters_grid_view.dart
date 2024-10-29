import 'package:flutter/material.dart';
import 'package:maid/classes/providers/characters.dart';
import 'package:maid/ui/shared/tiles/character_tile.dart';
import 'package:provider/provider.dart';
import 'package:maid/services/app_settings_service.dart';

class CharactersGridView extends StatefulWidget {
  const CharactersGridView({super.key});

  @override
  State<CharactersGridView> createState() => _CharactersGridViewState();
}

class _CharactersGridViewState extends State<CharactersGridView> {
  final AppSettingsService _settings = AppSettingsService();

  @override
  void initState() {
    super.initState();
    _loadSavedCharacter();
  }

  Future<void> _loadSavedCharacter() async {
    final savedCharacterId = _settings.getSelectedCharacter();
    if (savedCharacterId != null && mounted) {
      CharacterCollection.of(context).setCurrent(savedCharacterId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CharacterCollection>(
      builder: buildGridView
    );
  }

  Widget buildGridView(BuildContext context, CharacterCollection characters, Widget? child) {
    // Save character state and settings
    characters.save();
    _handleCharacterSelect(characters.current);

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

  void _handleCharacterSelect(Character? character) async {
    if (character == null) return;
    
    // Save the selection
    await _settings.saveSelectedCharacter(character.id);
    
    // Save additional character settings
    await _settings.saveCharacterSettings({
      'name': character.name,
      'personality': character.personality,
      // Add other relevant character settings
    });
  }
}