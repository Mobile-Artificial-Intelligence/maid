import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maid/main.dart';

enum ThemeType { dark, light }

class MaidTheme {
  static ThemeData _theme = _darkTheme;
  static ThemeData get theme => _theme;
  static ThemeData get darkTheme => _darkTheme;
  static ThemeData get lightTheme => _lightTheme;

  static final InputDecorationTheme darkInputDecorationTheme =
      InputDecorationTheme(
    contentPadding: const EdgeInsets.symmetric(
        horizontal: 20.0, vertical: 15.0), // Padding inside the TextField
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30.0),
      borderSide: BorderSide.none,
    ),
    labelStyle: const TextStyle(
        fontWeight: FontWeight.normal, color: Colors.grey, fontSize: 15.0),
    hintStyle: const TextStyle(
        fontWeight: FontWeight.normal, color: Colors.white, fontSize: 15.0),
    fillColor: Colors.grey.shade800,
    filled: true,
    floatingLabelBehavior: FloatingLabelBehavior.never,
  );

  static final InputDecorationTheme lightInputDecorationTheme =
      InputDecorationTheme(
    contentPadding: const EdgeInsets.symmetric(
        horizontal: 20.0, vertical: 15.0), // Padding inside the TextField
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30.0),
      borderSide: BorderSide.none,
    ),
    labelStyle: const TextStyle(
        fontWeight: FontWeight.normal, color: Colors.black, fontSize: 15.0),
    hintStyle: const TextStyle(
        fontWeight: FontWeight.normal, color: Colors.black, fontSize: 15.0),
    fillColor: Colors.white,
    filled: true,
    floatingLabelBehavior: FloatingLabelBehavior.never,
  );

  static Future<void> loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? themePref = prefs.getString('theme');

    // Switch case for theme preference
    switch (themePref) {
      case 'dark':
        _theme = _darkTheme;
        break;
      case 'light':
        _theme = _lightTheme;
        break;
      default:
        _theme = _darkTheme;
        break;
    }
  }

  static Future<void> setTheme(ThemeType type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    switch (type) {
      case ThemeType.dark:
        _theme = _darkTheme;
        await prefs.setString('theme', 'dark');
        break;
      case ThemeType.light:
        _theme = _lightTheme;
        await prefs.setString('theme', 'light');
        break;
      default:
        _theme = _darkTheme;
        await prefs.setString('theme', 'dark');
        break;
    }

    maidAppKey.currentState!.refreshApp();
  }

  static final ThemeData _darkTheme = ThemeData(
    iconTheme: const IconThemeData(color: Colors.white),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: Colors.white,
        fontSize: 30.0,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: Colors.white,
        fontSize: 15.0,
      ),
      titleSmall: TextStyle(
        color: Colors.white,
        fontSize: 20.0,
      ),
      bodyMedium: TextStyle(
        color: Colors.white,
        fontSize: 15.0,
        fontWeight: FontWeight.bold,
      ),
      labelLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    drawerTheme: DrawerThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
        ),
        backgroundColor: Colors.grey.shade900),
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20.0,
      ),
      inputDecorationTheme: darkInputDecorationTheme,
    ),
    scaffoldBackgroundColor: Colors.grey.shade900,
    textSelectionTheme: TextSelectionThemeData(
      selectionHandleColor: Colors.blue,
      selectionColor: Colors.blue.shade800,
    ),
    inputDecorationTheme: darkInputDecorationTheme,
    dialogTheme: DialogTheme(
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20.0,
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: Colors.blue.shade800,
      inactiveTrackColor: Colors.grey.shade800,
      thumbColor: Colors.blue,
      overlayColor: Colors.blue.shade800,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
          elevation: const MaterialStatePropertyAll(2.0),
          shadowColor: MaterialStatePropertyAll(Colors.black.withOpacity(0.8))),
    ),
    colorScheme: ColorScheme.dark(
      background: Colors.grey.shade900,
      primary: Colors.grey.shade800,
      onPrimary: Colors.white,
      secondary: Colors.blue,
      tertiary: Colors.blue.shade900,
      inversePrimary: const Color.fromARGB(255, 100, 20, 20),
    ),
  );

  static final ThemeData _lightTheme = ThemeData(
      iconTheme: const IconThemeData(color: Colors.black),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          color: Colors.black,
          fontSize: 30.0,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: Colors.black,
          fontSize: 15.0,
        ),
        titleSmall: TextStyle(
          color: Colors.black,
          fontSize: 20.0,
        ),
        bodyMedium: TextStyle(
          color: Colors.black,
          fontSize: 15.0,
          fontWeight: FontWeight.bold,
        ),
        labelLarge: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.black,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      drawerTheme: DrawerThemeData(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20)),
          ),
          backgroundColor: Colors.grey.shade200),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20.0,
        ),
        inputDecorationTheme: lightInputDecorationTheme,
      ),
      scaffoldBackgroundColor: Colors.grey.shade300,
      textSelectionTheme: TextSelectionThemeData(
        selectionHandleColor: Colors.blue,
        selectionColor: Colors.blue.shade800,
      ),
      inputDecorationTheme: lightInputDecorationTheme,
      dialogTheme: DialogTheme(
        backgroundColor: Colors.grey.shade300,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20.0,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: Colors.blue.shade800,
        inactiveTrackColor: Colors.white,
        thumbColor: Colors.blue,
        overlayColor: Colors.blue.shade800,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          elevation: const MaterialStatePropertyAll(1.0),
          shadowColor: MaterialStatePropertyAll(Colors.grey.withOpacity(0.5)),
        ),
      ),
      colorScheme: ColorScheme.light(
        primary: Colors.white,
        onPrimary: Colors.black,
        secondary: Colors.blue.shade300,
        background: Colors.grey.shade300,
        surface: Colors.grey.shade300,
        onBackground: Colors.black,
        onSurface: Colors.black,
        error: Colors.red,
        onError: Colors.white,
      ));
}
