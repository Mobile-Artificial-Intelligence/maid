import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModelFilePath {

  // static Future<Directory?> getDownloadPath() async {
  //   Directory? directory;
  //   try {
  //     //ask for permission
  //     if (Platform.isAndroid) {
  //       await Permission.storage.request();
  //       var status = await Permission.storage.request();
  //       if (!status.isGranted) {
  //         print("Permission denied : $status");
  //         return null;
  //         // We didn't ask for permission yet or the permission has been denied before but not permanently.
  //       }
  //     }
  //     if (Platform.isIOS) {
  //       directory = await getApplicationDocumentsDirectory();
  //       var newFolder = Directory('${directory.path}/Download');
  //       if (newFolder.existsSync() == false) {
  //         newFolder.createSync();
  //       }
  //       directory = newFolder;
  //     } else {
  //       directory = Directory('/storage/emulated/0/Download');
  //       // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
  //       // ignore: avoid_slow_async_io
  //       if (!await directory.exists()) {
  //         directory = await getExternalStorageDirectory();
  //       }
  //     }
  //   } catch (err, stack) {
  //     print("Cannot get download folder path");
  //   }
  //   return directory;
  // }



  static Future <String?>getFilePath() async {

    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('path') != null) {
      var path = prefs.getString('path')!;
      return path;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['bin'],
    );
    if (result != null) {
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