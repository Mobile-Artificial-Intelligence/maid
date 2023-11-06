import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:maid/utilities/memory_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class FileManager {
  static Future<File?> load(BuildContext context, List<String> allowedExtensions) async {
    if ((Platform.isAndroid || Platform.isIOS)) {
      if (!(await Permission.storage.request().isGranted) || 
          !(await Permission.manageExternalStorage.request().isGranted)
      ) {
        return null;
      }
    }
    
    Directory initialDirectory = await MemoryManager.getInitialDirectory();

    if (!context.mounted) return null;
  
  
    var result = await FilesystemPicker.open(
      allowedExtensions: allowedExtensions,
      context: context,
      rootDirectory: initialDirectory,
      fileTileSelectMode: FileTileSelectMode.wholeTile,
      fsType: FilesystemType.file
    );

    if (result == null) {
      return null;
    }

    return File(result);
  }
}