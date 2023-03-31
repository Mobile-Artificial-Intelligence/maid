import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModelFilePath {
  static Future<String?> getFilePath() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('path') != null) {
      var path = prefs.getString('path')!;
      return path;
    }
    try {
      await Permission.storage.request();
    } catch (e) {}
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['bin'],
    );
    if (result?.files.single.path != null) {
      prefs.setString('path', result!.files.single.path!);
      return result.files.single.path;
    } else {
      return null;
    }
  }

  static Future<bool> filePathExists() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('path') != null) {
      return true;
    }
    return false;
  }

  static deleteModelFile() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('path');
    });
  }
}
