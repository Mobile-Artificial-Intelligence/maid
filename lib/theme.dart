import 'package:flutter/material.dart';

class MaidTheme {
  ThemeData getTheme() {
    return _darkTheme;
  }

  // Inside MaidTheme class
  static ThemeData get darkTheme => _darkTheme;
  static ThemeData get lightTheme => _lightTheme;


  static final ThemeData _darkTheme = ThemeData(
    iconTheme: const IconThemeData(color: Colors.white),

    textTheme: const TextTheme(
      titleMedium: TextStyle(color: Colors.white),
      labelLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey.shade900,
      foregroundColor: Colors.white,
      titleTextStyle: const TextStyle(color: Colors.white),
      iconTheme: const IconThemeData(color: Colors.white),
    ),

    drawerTheme: DrawerThemeData(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20)),
      ),
      backgroundColor: Colors.grey.shade900
    ),

    scaffoldBackgroundColor: Colors.grey.shade900,
    textSelectionTheme: TextSelectionThemeData(
      selectionHandleColor: Colors.blue,
      selectionColor: Colors.blue.shade800,
    ),

    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0), // Padding inside the TextField
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide.none,
      ),
      labelStyle: const TextStyle(color: Colors.grey), // Style for the label
      hintStyle: const TextStyle(color: Colors.white),
      fillColor: Colors.grey.shade800,
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
    ),

    sliderTheme: SliderThemeData(
      activeTrackColor: Colors.blue.shade800,
      inactiveTrackColor: Colors.grey.shade800,
      thumbColor: Colors.blue,
      overlayColor: Colors.blue.shade800,
    ),

    colorScheme: ColorScheme.dark(
      background: Colors.grey.shade900,
      primary: Colors.grey.shade800,
      onPrimary: Colors.white,
      secondary: Colors.blue,
      inversePrimary: const Color.fromARGB(255, 100, 20, 20),
    ),
  );

  static final ThemeData _lightTheme = ThemeData(
    iconTheme: const IconThemeData(color: Colors.black),

    textTheme: const TextTheme(
      titleMedium: TextStyle(color: Colors.black),
      labelLarge: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey.shade300,
      foregroundColor: Colors.black,
      titleTextStyle: const TextStyle(color: Colors.black),
      iconTheme: const IconThemeData(color: Colors.black),
    ),

    drawerTheme: DrawerThemeData(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20)),
      ),
      backgroundColor: Colors.grey.shade300
    ),

    scaffoldBackgroundColor: Colors.grey.shade300,

    textSelectionTheme: TextSelectionThemeData(
      selectionHandleColor: Colors.blue,
      selectionColor: Colors.blue.shade800,
    ),

    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0), // Padding inside the TextField
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide.none,
      ),
      labelStyle: const TextStyle(color: Colors.black), // Style for the label
      hintStyle: const TextStyle(color: Colors.black),
      fillColor: Colors.white,
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
    ),

    sliderTheme: SliderThemeData(
      activeTrackColor: Colors.blue.shade800,
      inactiveTrackColor: Colors.white,
      thumbColor: Colors.blue,
      overlayColor: Colors.blue.shade800,
    ),

    colorScheme: ColorScheme.dark(
      background: Colors.grey.shade300,
      primary: Colors.white,
      onPrimary: Colors.black,
      secondary: Colors.blue,
      inversePrimary: const Color.fromARGB(255, 100, 20, 20),
    ),
  );
}