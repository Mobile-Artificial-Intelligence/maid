import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:maid/static/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class FileManager {
  static Future<File?> load(BuildContext context, String dialogTitle, List<String> allowedExtensions) async {
    if (Platform.isAndroid || Platform.isIOS) {
      // Check if the SDK version is Android 11 (API level 30) or higher
      if (Platform.isAndroid && Platform.operatingSystemVersion.contains("API 30")) {
        // Request for Manage External Storage
        if (!(await Permission.manageExternalStorage.request().isGranted)) {
          Logger.log("Storage - Permission denied");
          return null;
        }
      } else {
        // For older versions, use the storage permission
        if (!(await Permission.storage.request().isGranted)) {
          Logger.log("Storage - Permission denied");
          return null;
        }
      }

      Logger.log("Storage - Permission granted");
    }

    String? result;
    
    Directory initialDirectory;
    if (Platform.isAndroid) {
      initialDirectory = Directory("storage/emulated/0");

      if (!context.mounted) return null;
  
      result = await FilesystemPicker.open(
        allowedExtensions: allowedExtensions,
        context: context,
        rootDirectory: initialDirectory,
        fileTileSelectMode: FileTileSelectMode.wholeTile,
        fsType: FilesystemType.file
      );
    } else {
      FilePickerResult? pick = await FilePicker.platform.pickFiles(
        dialogTitle: dialogTitle,
        type: FileType.any,
        allowMultiple: false,
      );

      if (pick != null) {
        result = pick.files.single.path;
      }
    }

    if (result == null) {
      return null;
    }

    return File(result);
  }

  static Future<File?> save(BuildContext context, String fileName) async {
    if (Platform.isAndroid || Platform.isIOS) {
      // Check if the SDK version is Android 11 (API level 30) or higher
      if (Platform.isAndroid && Platform.operatingSystemVersion.contains("API 30")) {
        // Request for Manage External Storage
        if (!(await Permission.manageExternalStorage.request().isGranted)) {
          Logger.log("Storage - Permission denied");
          return null;
        }
      } else {
        // For older versions, use the storage permission
        if (!(await Permission.storage.request().isGranted)) {
          Logger.log("Storage - Permission denied");
          return null;
        }
      }

      Logger.log("Storage - Permission granted");
    }

    String? result;
    
    Directory initialDirectory;
    if (Platform.isAndroid) {
      initialDirectory = Directory("storage/emulated/0");

      if (!context.mounted) return null;
  
      result = await FilesystemPicker.open(
        title: 'Save to folder',
        context: context,
        rootDirectory: initialDirectory,
        fsType: FilesystemType.folder,
        pickText: 'Save file to this folder',
      );

      if (result != null) {
        result = "$result/$fileName";
      }
    } else {
      result = await FilePicker.platform.saveFile(
        dialogTitle: "Save Model File",
        type: FileType.any,
      );

      result.toString();
    }

    if (result == null) {
      return null;
    }

    return File(result);
  }

  static Future<File?> loadImage(BuildContext context, String dialogTitle) async {
    if (Platform.isAndroid || Platform.isIOS) {
      // Check if the SDK version is Android 11 (API level 30) or higher
      if (Platform.isAndroid && Platform.operatingSystemVersion.contains("API 30")) {
        // Request for Manage External Storage
        if (!(await Permission.manageExternalStorage.request().isGranted)) {
          Logger.log("Storage - Permission denied");
          return null;
        }
      } else {
        // For older versions, use the storage permission
        if (!(await Permission.storage.request().isGranted)) {
          Logger.log("Storage - Permission denied");
          return null;
        }
      }
    
      Logger.log("Storage - Permission granted");
    }

    String? result;
    
    FilePickerResult? pick = await FilePicker.platform.pickFiles(
      dialogTitle: dialogTitle,
      type: FileType.image,
      allowMultiple: false,
    );
    
    if (pick != null) {
      result = pick.files.single.path;
    }

    if (result == null) {
      return null;
    }

    return File(result);
  }

  static bool checkFileExists(String filePath) {
    File file = File(filePath);
    return file.existsSync();
  }
}
