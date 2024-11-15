import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:maid/classes/static/logger.dart';
import 'package:maid/classes/static/utilities.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User extends ChangeNotifier {
  static File? _customImage;

  static Future<File> get customImageFuture async {
    return _customImage ?? await Utilities.fileFromAssetImage("blankCustomUser.png");
  }

  Key _key = UniqueKey();
  File? _profile;
  String _name = "我";

  static User of(BuildContext context, { bool listen = false }) => Provider.of<User>(context, listen: listen);

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

  static Future<User> get last async {
    final prefs = await SharedPreferences.getInstance();

    String? lastUserString = prefs.getString("last_user");

    Map<String, dynamic> lastUser = json.decode(lastUserString ?? "{}");

    return User.fromMap(lastUser);
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString("last_user", json.encode(toMap()));
  }

  Future<File> get profile async {
    return _profile ?? await Utilities.fileFromAssetImage("defaultUser.png");
  }

  File? get profileFile => _profile;
  String get name => _name;
  
  Key get key => _key;

  set profile(Future<File> value) {
    value.then((File file) {
      _profile = file;
      notifyListeners();
    });
  }

  set name(String value) {
    _name = value;
    save().then((value) => notifyListeners());
  }

  void fromMap(Map<String, dynamic> inputMap) async {
    if (inputMap.isEmpty) {
      reset();
      return;
    }

    if (inputMap["customImage"] != null) {
      _customImage = File(inputMap["customImage"]);
    } else {
      _customImage = await Utilities.fileFromAssetImage("blankCustomUser.png");
    }

    if (inputMap["profile"] != null) {
      _profile = File(inputMap["profile"]);
    } else {
      _profile = await Utilities.fileFromAssetImage("defaultUser.png");
    }

    _name = inputMap["name"];
    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    return {
      "customImage": _customImage?.path,
      "profile": _profile?.path,
      "name": _name,
    };
  }

  void reset() async {
    _customImage = await Utilities.fileFromAssetImage("blankCustomUser.png");
    _profile = await Utilities.fileFromAssetImage("defaultUser.png");
    _name = "我";
    notifyListeners();
  }

  void loadImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: "Load Custom User Image",
        type: FileType.image,
      );

      if (result != null) {
        _customImage = File(result.files.single.path!);
        _profile = _customImage;
        notifyListeners();
      }
    } catch (e) {
      Logger.log("Failed to load image: $e");
    }
  }

  @override
  void notifyListeners() {
    _key = UniqueKey();
    super.notifyListeners();
  }
}
