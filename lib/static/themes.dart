import 'package:flutter/material.dart';

class Themes {
  static ThemeData lightTheme() {
    return genericTheme(
      Colors.white,
      Colors.grey.shade300,
      Colors.black,
      Colors.blue,
      Colors.blue.shade900,
      const Color.fromARGB(255, 100, 20, 20),
    );
  }

  static ThemeData darkTheme() {
    return genericTheme(
      Colors.grey.shade900,
      Colors.grey.shade800,
      Colors.white,
      Colors.blue,
      Colors.blue.shade900,
      const Color.fromARGB(255, 100, 20, 20),
    );
  }

  static ThemeData genericTheme(
    Color background,
    Color primary,
    Color onPrimary,
    Color secondary,
    Color tertiary,
    Color inversePrimary,
  ) {
    return ThemeData(
      iconTheme: IconThemeData(color: onPrimary),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          color: onPrimary,
          fontSize: 30.0,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: onPrimary,
          fontSize: 15.0,
        ),
        titleSmall: TextStyle(
          color: onPrimary,
          fontSize: 20.0,
        ),
        bodyMedium: TextStyle(
          color: onPrimary,
          fontSize: 15.0,
          fontWeight: FontWeight.bold,
        ),
        labelLarge: TextStyle(
          color: onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: onPrimary,
        titleTextStyle: TextStyle(
          color: onPrimary,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: onPrimary),
      ),
      drawerTheme: DrawerThemeData(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
          ),
          backgroundColor: background),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(
          color: onPrimary,
          fontSize: 20.0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 20.0, vertical: 15.0), // Padding inside the TextField
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          labelStyle: const TextStyle(
              fontWeight: FontWeight.normal, color: Colors.grey, fontSize: 15.0),
          hintStyle: TextStyle(
              fontWeight: FontWeight.normal, color: onPrimary, fontSize: 15.0),
          fillColor: primary,
          filled: true,
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
      ),
      scaffoldBackgroundColor: background,
      textSelectionTheme: TextSelectionThemeData(
        selectionHandleColor: secondary,
        selectionColor: tertiary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 20.0, vertical: 15.0), // Padding inside the TextField
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        labelStyle: const TextStyle(
            fontWeight: FontWeight.normal, color: Colors.grey, fontSize: 15.0),
        hintStyle: TextStyle(
            fontWeight: FontWeight.normal, color: onPrimary, fontSize: 15.0),
        fillColor: primary,
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: background,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        titleTextStyle: TextStyle(
          color: onPrimary,
          fontSize: 20.0,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: tertiary,
        inactiveTrackColor: primary,
        thumbColor: secondary,
        overlayColor: tertiary,
      ),
      colorScheme: ColorScheme.dark(
        background: background,
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        tertiary: tertiary,
        inversePrimary: const Color.fromARGB(255, 100, 20, 20),
      ),
    );
  }
}