import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

ThemeData lightTheme = ThemeData(
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
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey.shade200,
      foregroundColor: Colors.black,
      titleTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: Colors.black),
    ),
    drawerTheme: const DrawerThemeData(
        shape:RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20)),
        ),
        backgroundColor: Colors.white),
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: const TextStyle(
        color: Colors.black,
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
            fontWeight: FontWeight.normal, color: Colors.black, fontSize: 15.0),
        hintStyle: const TextStyle(
            fontWeight: FontWeight.normal, color: Colors.grey, fontSize: 15.0),
        fillColor: Colors.grey.shade300,
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
      ),
    ),
    scaffoldBackgroundColor: Colors.white,
    textSelectionTheme: TextSelectionThemeData(
      selectionHandleColor: Colors.blue,
      selectionColor: Colors.blue.shade800,
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 20.0, vertical: 15.0), // Padding inside the TextField
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide.none,
      ),
      labelStyle: const TextStyle(
          fontWeight: FontWeight.normal, color: Colors.black, fontSize: 15.0),
      hintStyle: const TextStyle(
          fontWeight: FontWeight.normal, color: Colors.grey, fontSize: 15.0),
      fillColor: Colors.grey.shade300,
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
    ),
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
    colorScheme: ColorScheme.light(
      background: Colors.white,
      primary: Colors.grey.shade300,
      onPrimary: Colors.black,
      secondary: Colors.blue,
      tertiary: Colors.blue.shade900,
      inversePrimary: const Color.fromARGB(255, 100, 20, 20),
    )
);

ThemeData darkTheme = ThemeData(
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
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey.shade900,
    foregroundColor: Colors.white,
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
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
    inputDecorationTheme: InputDecorationTheme(
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
    ),
  ),
  scaffoldBackgroundColor: Colors.grey.shade900,
  textSelectionTheme: TextSelectionThemeData(
    selectionHandleColor: Colors.blue,
    selectionColor: Colors.blue.shade800,
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
    hintStyle: const TextStyle(
        fontWeight: FontWeight.normal, color: Colors.white, fontSize: 15.0),
    fillColor: Colors.grey.shade800,
    filled: true,
    floatingLabelBehavior: FloatingLabelBehavior.never,
  ),
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
  colorScheme: ColorScheme.dark(
    background: Colors.grey.shade900,
    primary: Colors.grey.shade800,
    onPrimary: Colors.white,
    secondary: Colors.blue,
    tertiary: Colors.blue.shade900,
    inversePrimary: const Color.fromARGB(255, 100, 20, 20),
  ),
);