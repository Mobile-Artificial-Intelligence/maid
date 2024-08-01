import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maid/enumerators/app_layout.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences extends ChangeNotifier {
  bool _autoTextToSpeech = true;

  ThemeMode _themeMode = ThemeMode.dark;
  AppLayout _appLayout = AppLayout.system;

  bool get autoTextToSpeech => _autoTextToSpeech;

  ThemeMode get themeMode => _themeMode;

  AppLayout get appLayout => _appLayout;

  bool get isDesktop {
    if (_appLayout == AppLayout.system) {
      return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    }

    return _appLayout == AppLayout.desktop;
  }

  bool get isMobile {
    if (_appLayout == AppLayout.system) {
      return Platform.isAndroid || Platform.isIOS;
    }

    return _appLayout == AppLayout.mobile;
  }

  static AppPreferences of(BuildContext context) => Provider.of<AppPreferences>(context, listen: false);

  AppPreferences(bool autoTextToSpeech, ThemeMode themeMode, AppLayout appLayout) : 
    _autoTextToSpeech = autoTextToSpeech,
    _themeMode = themeMode, 
    _appLayout = appLayout;

  static Future<AppPreferences> get last async {
    final prefs = await SharedPreferences.getInstance();

    bool autoTextToSpeech = prefs.getBool("auto_text_to_speech") ?? true;
    int themeModeIndex = prefs.getInt("theme_mode") ?? ThemeMode.dark.index;
    int appLayoutIndex = prefs.getInt("app_layout") ?? AppLayout.system.index;

    return AppPreferences(
      autoTextToSpeech,
      ThemeMode.values[themeModeIndex], 
      AppLayout.values[appLayoutIndex]
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setBool("auto_text_to_speech", _autoTextToSpeech);
    prefs.setInt("theme_mode", _themeMode.index);
    prefs.setInt("app_layout", _appLayout.index);
  }

  set autoTextToSpeech(bool value) {
    _autoTextToSpeech = value;
    save();
    notifyListeners();
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