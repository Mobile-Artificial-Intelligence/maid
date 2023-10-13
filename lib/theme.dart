import 'package:flutter/material.dart';

class MaidTheme {
  ThemeData getTheme() {
    return _darkTheme;
  }

  static final ThemeData _darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey.shade900,
    colorScheme: ColorScheme.dark(
      background: Colors.grey.shade900,
      primary: Colors.grey.shade800,
      secondary: Colors.blue,
      inversePrimary: const Color.fromARGB(255, 100, 20, 20),
    ),
  );
}

InputDecoration roundedInput(labelText, context) {
  return InputDecoration(
    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0), // Padding inside the TextField
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30.0),
      borderSide: BorderSide.none,
    ),
    labelText: labelText,
    labelStyle: const TextStyle(color: Colors.grey), // Style for the label
    fillColor: Theme.of(context).colorScheme.primary,
    filled: true,
    floatingLabelBehavior: FloatingLabelBehavior.never,
  );
}