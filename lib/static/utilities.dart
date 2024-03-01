import 'package:flutter/material.dart';

class Utilities {
  static String keyToString(Key key) {
    return key.toString().replaceAll('<\'[', '').replaceAll(']\'>', '');
  }

  static String formatPlaceholders(
      String input, String userName, String characterName) {
    input = replaceCaseInsensitive(input, "{{char}}", characterName);
    input = replaceCaseInsensitive(input, "<BOT>", characterName);
    input = replaceCaseInsensitive(input, "{{user}}", userName);
    input = replaceCaseInsensitive(input, "<USER>", userName);

    return input;
  }

  static String replaceCaseInsensitive(
      String original, String from, String replaceWith) {
    // This creates a regular expression that ignores case (case-insensitive)
    RegExp exp = RegExp(RegExp.escape(from), caseSensitive: false);
    return original.replaceAll(exp, replaceWith);
  }
}