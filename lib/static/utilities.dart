import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class Utilities {
  static String formatPlaceholders(
    String input, 
    String userName, 
    String characterName
  ) {
    input = replaceCaseInsensitive(input, "{{char}}", characterName);
    input = replaceCaseInsensitive(input, "<BOT>", characterName);
    input = replaceCaseInsensitive(input, "{{user}}", userName);
    input = replaceCaseInsensitive(input, "<USER>", userName);

    return input;
  }

  static String replaceCaseInsensitive(
    String original, 
    String from, 
    String replaceWith
  ) {
    // This creates a regular expression that ignores case (case-insensitive)
    RegExp exp = RegExp(RegExp.escape(from), caseSensitive: false);
    return original.replaceAll(exp, replaceWith);
  }

  static Future<File> fileFromAssetImage(String asset) async {
    final assetPath = 'assets/$asset';

    final docDir = await getTemporaryDirectory();

    final path = '${docDir.path}/$asset';

    final byteData = await rootBundle.load(assetPath);

    final buffer = byteData.buffer.asUint8List();

    return File(path)..writeAsBytesSync(buffer);
  }

  static String capitalizeFirst(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }
}