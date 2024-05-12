import 'package:flutter/material.dart';

class Themes {
  static ThemeData lightTheme() {
    return genericTheme(
      background: Colors.white,
      onBackground: Colors.grey.shade700,
      primary: Colors.grey.shade300,
      onPrimary: Colors.black,
      secondary: Colors.blue,
      tertiary: Colors.blue.shade900,
      inversePrimary: const Color.fromARGB(255, 100, 20, 20),
      isDark: false,
    );
  }

  static ThemeData darkTheme() {
    return genericTheme(
      background: Colors.grey.shade900,
      onBackground: Colors.black,
      primary: Colors.grey.shade800,
      onPrimary: Colors.white,
      secondary: Colors.blue,
      tertiary: Colors.blue.shade900,
      inversePrimary: const Color.fromARGB(255, 100, 20, 20),
      isDark: true,
    );
  }

  static ThemeData genericTheme({
    required Color background,
    required Color onBackground,
    required Color primary,
    required Color onPrimary,
    required Color secondary,
    required Color tertiary,
    required Color inversePrimary,
    required bool isDark,
  }) {
    return ThemeData(
      dialogTheme: DialogTheme(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))
        ),
        titleTextStyle: TextStyle(
          color: onPrimary,
          fontSize: 20.0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(Colors.white),
          backgroundColor: MaterialStateProperty.all(secondary),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.all(Colors.white),
        trackColor: MaterialStateProperty.all(secondary),
        trackOutlineColor: MaterialStateProperty.all(secondary)
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: tertiary,
        inactiveTrackColor: primary,
        thumbColor: secondary,
        overlayColor: tertiary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20.0, 
          vertical: 15.0
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        fillColor: primary,
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
      ),
      textSelectionTheme: TextSelectionThemeData(
        selectionHandleColor: secondary,
        selectionColor: tertiary,
        cursorColor: secondary,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: secondary,
      ),
      colorScheme: isDark ? ColorScheme.dark(
        background: background,
        onBackground: onBackground,
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        tertiary: tertiary,
        inversePrimary: inversePrimary,
      ) : ColorScheme.light(
        background: background,
        onBackground: onBackground,
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        tertiary: tertiary,
        inversePrimary: inversePrimary,
      )
    );
  }
}
