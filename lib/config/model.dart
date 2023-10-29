import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

Model model = Model();

class Model { 
  Map<String, dynamic> parameters = {};

  bool busy = false;

  late String modelPath;

  Model() {
    initFromSharedPrefs();
  }

  void initFromSharedPrefs() async {
    var prefs = await SharedPreferences.getInstance();

    parameters = json.decode(prefs.getString("model") ?? "{}");

    if (parameters.isEmpty) {
      resetAll();
    }

    modelPath = parameters["modelPath"] ?? "";
  }

  void saveSharedPreferences() async {
    parameters["modelPath"] = modelPath;
    
    var prefs = await SharedPreferences.getInstance();

    prefs.setString("model", json.encode(parameters));
  }

  void resetAll() async {
    // Reset all the internal state to the defaults
    String jsonString = await rootBundle.loadString('assets/default_parameters.json');

    parameters = json.decode(jsonString);

    // Clear values from SharedPreferences
    var prefs = await SharedPreferences.getInstance();
    prefs.clear();

    // It might be a good idea to save the default model after a reset
    saveSharedPreferences();
  }

  Future<String> saveModelToJson() async {
    parameters["modelPath"] = modelPath;

    // Convert the map to a JSON string
    String jsonString = json.encode(parameters);
    String? filePath;

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        Directory? directory;
        if (Platform.isAndroid && (await Permission.manageExternalStorage.request().isGranted)) {
          directory = await Directory('/storage/emulated/0/Download/Maid').create();
        } 
        else if (Platform.isIOS && (await Permission.storage.request().isGranted)) {
          directory = await getDownloadsDirectory();
        } else {
          return "Permission Request Failed";
        }

        filePath = '${directory!.path}/maid_model.json';
      }
      else {
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

  Future<String> loadModelFromJson() async {
    if ((Platform.isAndroid || Platform.isIOS) && 
        !(await Permission.storage.request().isGranted)) {
      return "Permission Request Failed";
    }
    
    try{
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result == null) return "No File Selected";

      File file = File(result.files.single.path!);
      String jsonString = await file.readAsString();
      if (jsonString.isEmpty) return "Failed to load model";
      
      parameters = json.decode(jsonString);
      if (parameters.isEmpty) {
        resetAll();
        return "Failed to decode model";
      }

      modelPath = parameters['modelPath'];
    } catch (e) {
      resetAll();
      return "Error: $e";
    }

    return "Model Successfully Loaded";
  }

  Future<String> loadModelFile() async {
    if ((Platform.isAndroid || Platform.isIOS)) {
      if (!(await Permission.storage.request().isGranted)) {
        return "Permission Request Failed";
      }

      if (modelPath.isNotEmpty) await FilePicker.platform.clearTemporaryFiles();
    }
  
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: "Select Model File",
        type: FileType.any,
        allowMultiple: false,
        onFileLoading: (FilePickerStatus status) => busy = status == FilePickerStatus.picking
      );
      final filePath = result?.files.single.path;
  
      if (filePath == null) {
        return "Failed to load model";
      }
      
      modelPath = filePath;
      parameters["modelName"] = path.basename(filePath);
    } catch (e) {
      return "Error: $e";
    }
  
    return "Model Successfully Loaded";
  }
}