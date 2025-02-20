part of 'package:maid/main.dart';

extension SillyTavernExtension on AppSettings {
  void sillyTavernDecoder(Map<String, String>? imageData) {
    if (imageData == null) return;

    Uint8List utf8Character = base64.decode(imageData["Chara"] ?? imageData["chara"] ?? '');

    String stringCharacter = utf8.decode(utf8Character);

    Map<String, dynamic> character = jsonDecode(stringCharacter);

    if (character.isEmpty) return;

    String result = '';

    if (character['data'] != null) {
      character = character['data'];
    }

    final name = character['name'] as String?;
    if (name != null && name.trim().isNotEmpty) {
      result += '### Character Name: ${name.titleize}\n\n';
      assistantName = name;
    }

    final description = character['description'] as String?;
    if (description != null && description.trim().isNotEmpty) {
      result += '### Description\n\n${description.titleize}\n\n';
    }

    final personality = character['personality'] as String?;
    if (personality != null && personality.trim().isNotEmpty) {
      result += '### Personality\n\n${personality.titleize}\n\n';
    }

    final scenario = character['scenario'] as String?;
    if (scenario != null && scenario.trim().isNotEmpty) {
      result += '### Scenario\n\n${scenario.titleize}\n\n';
    }

    final example = character['mes_example'] as String?;
    if (example != null && example.trim().isNotEmpty) {
      result += '### Message Example\n\n${example.titleize}\n\n';
    }

    systemPrompt = result;
  }
}