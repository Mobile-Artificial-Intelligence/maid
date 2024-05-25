import 'package:flutter/material.dart';

class AppPreferences extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  set themeMode(ThemeMode value) {
    _themeMode = value;
    notifyListeners();
  }

  void reset() {
    notifyListeners();
  }
}