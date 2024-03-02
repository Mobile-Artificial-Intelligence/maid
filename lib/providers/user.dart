import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User extends ChangeNotifier {
  File _profile = File("assets/chadUser.png");
  String _name = "User";

  File get profile => _profile;

  String get name => _name;

  set profile(File value) {
    _profile = value;
    notifyListeners();
  }

  set name(String value) {
    _name = value;
    notifyListeners();
  }

  void init() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastUser =
        json.decode(prefs.getString("last_user") ?? "{}") ?? {};

    if (lastUser.isNotEmpty) {
      fromMap(lastUser);
    } else {
      reset();
    }

    notifyListeners();
  }

  void fromMap(Map<String, dynamic> inputJson) {
    if (inputJson["profile"] != null) {
      _profile = File(inputJson["profile"]);
    } else {
      _profile = File("assets/chadUser.png");
    }

    _name = inputJson["name"];
    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    return {
      "profile": _profile.path,
      "name": _name,
    };
  }

  void reset() {
    _profile = File("assets/chadUser.png");
    _name = "User";
    notifyListeners();
  }
}
