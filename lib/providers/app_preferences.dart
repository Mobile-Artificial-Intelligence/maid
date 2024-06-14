import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maid/enumerators/app_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  AppLayout _appLayout = AppLayout.system;

  ThemeMode get themeMode => _themeMode;

  AppLayout get appLayout => _appLayout;

  bool get useDesktopLayout {
    if (_appLayout == AppLayout.system) {
      return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    }

    return _appLayout == AppLayout.desktop;
  }

  bool get useMobileLayout {
    if (_appLayout == AppLayout.system) {
      return Platform.isAndroid || Platform.isIOS;
    }

    return _appLayout == AppLayout.mobile;
  }

  AppPreferences(ThemeMode themeMode, AppLayout appLayout) : 
    _themeMode = themeMode, 
    _appLayout = appLayout;

  static Future<AppPreferences> get last async {
    final prefs = await SharedPreferences.getInstance();

    int themeModeIndex = prefs.getInt("theme_mode") ?? ThemeMode.dark.index;
    int appLayoutIndex = prefs.getInt("app_layout") ?? AppLayout.system.index;

    return AppPreferences(
      ThemeMode.values[themeModeIndex], 
      AppLayout.values[appLayoutIndex]
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setInt("theme_mode", _themeMode.index);
    prefs.setInt("app_layout", _appLayout.index);
  }

  set themeMode(ThemeMode value) {
    _themeMode = value;
    save();
    notifyListeners();
  }

  set appLayout(AppLayout value) {
    _appLayout = value;
    notifyListeners();
  }

  void reset() {
    notifyListeners();
  }
}