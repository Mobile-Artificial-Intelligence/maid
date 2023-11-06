import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class FileManager {
  static bool busy = false;

  static Future<File?> load(BuildContext context, List<String> allowedExtensions) async {
    if ((Platform.isAndroid || Platform.isIOS)) {
      if (!(await Permission.storage.request().isGranted) || 
          !(await Permission.manageExternalStorage.request().isGranted)
      ) {
        return null;
      }
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
        dialogTitle: "Select Model File",
        type: FileType.any,
        allowMultiple: false,
        onFileLoading: (FilePickerStatus status) => busy = status == FilePickerStatus.picking
      );

      if (pick != null) {
        result = pick.files.single.path;
      }
    }

    if (result == null) {
      busy = false;
      return null;
    }

    return File(result);
  }

  static Future<File?> save(BuildContext context, String character) async {
    if ((Platform.isAndroid || Platform.isIOS)) {
      if (!(await Permission.storage.request().isGranted) || 
          !(await Permission.manageExternalStorage.request().isGranted)
      ) {
        return null;
      }
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
        result = "$result/$character.json";
      }
    } else {
      result = await FilePicker.platform.saveFile(
        dialogTitle: "Save Model File",
        type: FileType.any,
      );

      result.toString();
    }

    if (result == null) {
      busy = false;
      return null;
    }

    return File(result);
  }
}