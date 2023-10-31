import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:maid/config/settings.dart';

Model model = Model();

class Model { 
  TextEditingController nameController = TextEditingController();
  
  Map<String, dynamic> parameters = {};

  bool busy = false;

  Model() {
    resetAll();
  }

  Model.fromMap(Map<String, dynamic> inputJson) {
    nameController.text = inputJson["name"] ?? "Default";
    if (inputJson.isEmpty) {
      resetAll();
    } else {
      parameters = inputJson;
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> jsonModel = {};

    jsonModel = parameters;
    jsonModel["name"] = getName();
    print("Name: ${getName()}");

    return jsonModel;
  }

  String getName() {
    if (nameController.text.isEmpty) return "Default";
    return nameController.text;
  }

  void resetAll() async {
    // Reset all the internal state to the defaults
    String jsonString = await rootBundle.loadString('assets/default_parameters.json');

    parameters = json.decode(jsonString);

    settings.save();
  }

  Future<String> saveParametersToJson() async {
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

  Future<String> loadParametersFromJson() async {
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
      
      parameters["model_path"] = filePath;
      parameters["model_name"] = path.basename(filePath);
    } catch (e) {
      return "Error: $e";
    }
  
    return "Model Successfully Loaded";
  }
}