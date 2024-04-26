import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maid/static/utilities.dart';

class User extends ChangeNotifier {
  Key _key = UniqueKey();
  File? _profile;
  String _name = "User";

  User() {
    reset();
  }

  User.from(User user) {
    _key = user.key;
    _profile = user.profileFile;
    _name = user.name;
  }

  User.fromMap(Map<String, dynamic> inputMap) {
    fromMap(inputMap);
  }

  Future<File> get profile async {
    return _profile ?? await Utilities.fileFromAssetImage("chadUser.png");
  }

  File? get profileFile => _profile;
  String get name => _name;
  
  Key get key => _key;

  set profile(Future<File> value) {
    value.then((File file) {
      _profile = file;
      notify();
    });
  }

  set name(String value) {
    _name = value;
    notify();
  }

  void fromMap(Map<String, dynamic> inputMap) async {
    if (inputMap.isEmpty) {
      reset();
      return;
    }

    if (inputMap["profile"] != null) {
      _profile = File(inputMap["profile"]);
    } else {
      _profile ??= await Utilities.fileFromAssetImage("chadUser.png");
    }

    _name = inputMap["name"];
    notify();
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
    notify();
  }

  void notify() {
    _key = UniqueKey();
    notifyListeners();
  }
}
