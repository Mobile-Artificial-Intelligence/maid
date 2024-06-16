import 'package:flutter/material.dart';

class Themes {
  static ThemeData lightTheme() {
    return genericTheme(
      surfaceDim: Colors.grey.shade200,
      primary: Colors.grey.shade400,
      onPrimary: Colors.black,
      secondary: Colors.blue,
      tertiary: Colors.blue.shade900,
      inversePrimary: Colors.orange.shade600,
      isDark: false,
    );
  }

  static ThemeData darkTheme() {
    return genericTheme(
      surfaceDim: Colors.grey.shade900,
      primary: Colors.grey.shade800,
      onPrimary: Colors.white,
      secondary: Colors.blue,
      tertiary: Colors.blue.shade900,
      inversePrimary: Colors.orange.shade600,
      isDark: true,
    );
  }

  static ThemeData genericTheme({
    required Color surfaceDim,
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
          foregroundColor: WidgetStateProperty.all(Colors.white),
          backgroundColor: WidgetStateProperty.all(secondary),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.all(secondary),
        trackOutlineColor: WidgetStateProperty.all(secondary)
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
        surfaceDim: surfaceDim,
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        tertiary: tertiary,
        inversePrimary: inversePrimary,
      ) : ColorScheme.light(
        surface: surfaceDim,
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        tertiary: tertiary,
        inversePrimary: inversePrimary,
      )
    );
  }
}
