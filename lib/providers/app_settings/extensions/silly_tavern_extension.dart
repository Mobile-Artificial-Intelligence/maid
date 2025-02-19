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

    if (character['name'] != null && character['name'] is String) {
      final name = character['name'] as String;
      result += '### Character Name: ${name.titleize}\n\n';
      assistantName = name;
    }

    if (character['description'] != null && character['description'] is String) {
      result += '### Description\n\n${(character['description'] as String).titleize}\n\n';
    }

    if (character['personality'] != null && character['personality'] is String) {
      result += '### Personality\n\n${(character['personality'] as String).titleize}\n\n';
    }

    if (character['scenario'] != null && character['scenario'] is String) {
      result += '### Scenario\n\n${(character['scenario'] as String).titleize}\n\n';
    }

    if (character['mes_example'] != null && character['mes_example'] is String) {
      result += '### Message Example\n\n${(character['mes_example'] as String).titleize}\n\n';
    }

    systemPrompt = result;
  }
}