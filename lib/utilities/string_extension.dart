part of 'package:maid/main.dart';

extension StringExtension on String {
  String formatPlaceholders(
    String userName, 
    String characterName
  ) {
    String result = this;

    final charExp = RegExp(r'{{char}}|<BOT>', caseSensitive: false);
    result = result.replaceAll(charExp, characterName);

    final userExp = RegExp(r'{{user}}|<USER>', caseSensitive: false);
    result = result.replaceAll(userExp, userName);

    return result;
  }

  String get firstCapitalized {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}