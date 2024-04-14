import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:maid/static/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class FileManager {
  static Future<bool> _checkPermissions() async {
    if (Platform.isAndroid || Platform.isIOS) {
      bool isAndroid11OrAbove = false;

      if (Platform.isAndroid) {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        int sdkVersion = androidInfo.version.sdkInt;
        isAndroid11OrAbove = sdkVersion >= 30;

        if (isAndroid11OrAbove) {
          // Request for Manage External Storage
          if (!(await Permission.manageExternalStorage.request().isGranted)) {
            Logger.log("Storage - Permission denied");
            return false;
          }
        } else {
          // For older versions, use the storage permission
          if (!(await Permission.storage.request().isGranted)) {
            Logger.log("Storage - Permission denied");
            return false;
          }
        }
      }
    }

    Logger.log("Storage - Permission granted");
    return true;
  }

  static Future<File?> load(BuildContext context, String dialogTitle,
      List<String> allowedExtensions) async {
    final bool permissionGranted = await _checkPermissions();
    if (!permissionGranted) {
      return null;
    }

    String? result;

    if (Platform.isAndroid) {
      if (!context.mounted) return null;

      result = await FilesystemPicker.open(
        allowedExtensions: allowedExtensions,
        context: context,
        fileTileSelectMode: FileTileSelectMode.wholeTile,
        fsType: FilesystemType.file,
        shortcuts: [
          FilesystemPickerShortcut(
            name: 'Home',
            path: Directory("storage/emulated/0"),
          ),
          FilesystemPickerShortcut(
            name: 'SD Card',
            path: Directory("storage/emulated/1"),
          ),
        ],
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
    final bool permissionGranted = await _checkPermissions();
    if (!permissionGranted) {
      return null;
    }

    String? result;

    if (Platform.isAndroid) {
      if (!context.mounted) return null;

      result = await FilesystemPicker.open(
        title: 'Save to folder',
        context: context,
        fsType: FilesystemType.folder,
        pickText: 'Save file to this folder',
        shortcuts: [
          FilesystemPickerShortcut(
            name: 'Home',
            path: Directory("storage/emulated/0"),
          ),
          FilesystemPickerShortcut(
            name: 'SD Card',
            path: Directory("storage/emulated/1"),
          ),
        ],
      );

      if (result != null) {
        result = "$result/$fileName";
      }
    } else {
      result = await FilePicker.platform.saveFile(
        dialogTitle: "Save Model File",
        type: FileType.any,
      );
    }

    if (result == null) {
      return null;
    }

    return File(result);
  }

  static Future<File?> loadImage(
      BuildContext context, String dialogTitle) async {
    final bool permissionGranted = await _checkPermissions();
    if (!permissionGranted) {
      return null;
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
      Logger.log("Image file not selected");
      return null;
    }

    return File(result);
  }

  static bool checkFileExists(String filePath) {
    File file = File(filePath);
    return file.existsSync();
  }
}
