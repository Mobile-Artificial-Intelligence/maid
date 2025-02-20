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

  String get titleize {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  String get hash {
    // Convert to bytes
    final bytes = utf8.encode(this);

    // Compute hash
    final digest = sha256.convert(bytes);

    return digest.toString();
  }

  String pascalToSentence() {
    return replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) => '${match[1]} ${match[2]}')
      .replaceFirstMapped(RegExp(r'^[a-z]'), (match) => match[0]!.toUpperCase());
  }

  double jaccardSimilarity(String other) {
    Set<String> setA = split('').toSet();
    Set<String> setB = other.split('').toSet();

    int intersection = setA.intersection(setB).length;
    int union = setA.union(setB).length;

    return union == 0 ? 0.0 : intersection / union;
  }

  bool isSimilar(String other, {double threshold = 0.8}) {
    return jaccardSimilarity(other) >= threshold;
  }
} 