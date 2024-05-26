import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  AppPreferences(ThemeMode themeMode) : _themeMode = themeMode;

  static Future<AppPreferences> get last async {
    final prefs = await SharedPreferences.getInstance();

    int themeModeIndex = prefs.getInt("theme_mode") ?? ThemeMode.dark.index;

    return AppPreferences(ThemeMode.values[themeModeIndex]);
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setInt("theme_mode", _themeMode.index);
  }

  set themeMode(ThemeMode value) {
    _themeMode = value;
    save();
    notifyListeners();
  }

  void reset() {
    notifyListeners();
  }
}