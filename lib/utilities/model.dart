import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maid/utilities/logger.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:maid/utilities/memory_manager.dart';
import 'package:filesystem_picker/filesystem_picker.dart';

Model model = Model();

class Model {
  String name = "Default";
  Map<String, dynamic> parameters = {};

  bool busy = false;

  Model() {
    resetAll();
  }

  Model.fromMap(Map<String, dynamic> inputJson) {
    if (inputJson.isEmpty) {
      resetAll();
    } else {
      name = inputJson["name"] ?? "Default";
      Logger.log("Model created with name: ${inputJson["name"]}");
      parameters = inputJson;
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> jsonModel = {};

    jsonModel = parameters;
    jsonModel["name"] = name;
    Logger.log("JSON created with name: $name");

    return jsonModel;
  }

  void resetAll() async {
    // Reset all the internal state to the defaults
    String jsonString =
        await rootBundle.loadString('assets/default_parameters.json');

    parameters = json.decode(jsonString);

    memoryManager.save();
  }

  Future<String> saveParametersToJson() async {
    parameters["name"] = name;

    // Convert the map to a JSON string
    String jsonString = json.encode(parameters);
    String? filePath;

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        Directory? directory;

        if (Platform.isAndroid &&
            (await Permission.manageExternalStorage.request().isGranted)) {
          directory =
              await Directory('/storage/emulated/0/Download/Maid').create();
        } else if (Platform.isIOS &&
            (await Permission.storage.request().isGranted)) {
          directory = await getDownloadsDirectory();
        } else {
          return "Permission Request Failed";
        }

        filePath = '${directory!.path}/maid_model.json';
      } else {
        filePath = await FilePicker.platform.saveFile(type: FileType.any);
      }

      if (filePath != null) {
        File file = File(filePath);
        await file.writeAsString(jsonString);
      } else {
        return "No File Selected";
      }
    } catch (e) {
      return "Error: $e";
    }
    return "Model Successfully Saved to $filePath";
  }

  Future<String> loadParametersFromJson() async {
    if ((Platform.isAndroid || Platform.isIOS) &&
        !(await Permission.storage.request().isGranted)) {
      return "Permission Request Failed";
    }

    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result == null) return "No File Selected";

      File file = File(result.files.single.path!);
      String jsonString = await file.readAsString();
      if (jsonString.isEmpty) return "Failed to load model";

      parameters = json.decode(jsonString);
      if (parameters.isEmpty) {
        resetAll();
        return "Failed to decode model";
      } else {
        name = parameters["name"] ?? "Default";
      }
    } catch (e) {
      resetAll();
      return "Error: $e";
    }

    return "Model Successfully Loaded";
  }

  Future<String> loadModelFile(BuildContext context) async {
    Directory appDocDir;
    if (Platform.isAndroid) {
      appDocDir = Directory("storage/emulated/0");
    } else if (Platform.isLinux) {
      appDocDir = Directory('${Platform.environment['HOME']}/');
    } else {
      appDocDir = await getApplicationDocumentsDirectory();
    }
    if ((Platform.isAndroid || Platform.isIOS)) {
      await Permission.manageExternalStorage.request();
      if (!(await Permission.storage.request().isGranted)) {
        return "Permission Request Failed";
      }
    }

    final localContext = context;
    if (!context.mounted) return "Failed to load model";

    try {
      var result = await FilesystemPicker.open(
          allowedExtensions: [".gguf"],
          context: localContext,
          rootDirectory: appDocDir,
          fileTileSelectMode: FileTileSelectMode.wholeTile,
          fsType: FilesystemType.file);

      if (result == null) {
        busy = false;
        return "Failed to load model";
      }

      File file = File(result);
      Logger.log("Loading model from $file");

      parameters["model_path"] = file.path;
      parameters["model_name"] = path.basename(file.path);
    } catch (e) {
      return "Error: $e";
    }

    return "Model Successfully Loaded";
  }
}
