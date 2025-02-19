part of 'package:maid/main.dart';

String sillyTavernDecoder(Map<String, String>? imageData) {
  if (imageData == null) return '';

  Map<String, dynamic> character = jsonDecode(imageData['chara'] ?? imageData['Chara'] ?? '{}');

  if (character.isEmpty) return '';

  String result = '';

  if (character['data'] != null) {
    character = character['data'];
  }

  if (character['name'] != null && character['name'] is String) {
    result += '### Character Name: ${(character['name'] as String).titleize}\n\n';
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

  return result;
}