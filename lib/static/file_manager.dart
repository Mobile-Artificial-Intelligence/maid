import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:maid/static/logger.dart';

class FileManager {
  static Future<File?> load(
    String dialogTitle,
    FileType fileType,
  ) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: dialogTitle,
      type: FileType.any,
      allowMultiple: false,
      allowCompression: false
    );

    if (result != null && result.files.isNotEmpty) {
      Logger.log("File selected: ${result.files.single.path}");
      return File(result.files.single.path!);
    } else {
      Logger.log("No file selected");
      return null;
    }
  }

  static Future<File?> save(String fileName) async {
    String? result = await FilePicker.platform.saveFile(
      dialogTitle: "Save Model File",
      type: FileType.any,
    );

    if (result != null) {
      Logger.log("File saved: $result");
      return File(result);
    } else {
      Logger.log("File not saved");
      return null;
    }
  }

  static bool checkFileExists(String filePath) {
    File file = File(filePath);
    return file.existsSync();
  }
}
