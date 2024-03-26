import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/static/utilities.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User extends ChangeNotifier {
  File? _profile;
  String _name = "User";

  Future<File> get profile async {
    return _profile ?? await Utilities.fileFromAssetImage("chadUser.png");
  }

  String get name => _name;

  set profile(Future<File> value) {
    value.then((File file) {
      _profile = file;
      notifyListeners();
    });
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

  void fromMap(Map<String, dynamic> inputJson) async {
    if (inputJson["profile"] != null) {
      _profile = File(inputJson["profile"]);
    } else {
      _profile ??= await Utilities.fileFromAssetImage("chadUser.png");
    }

    _name = inputJson["name"];
    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    return {
      "profile": _profile!.path,
      "name": _name,
    };
  }

  void reset() async {
    _profile = await Utilities.fileFromAssetImage("chadUser.png");
    _name = "User";
    notifyListeners();
  }
}
