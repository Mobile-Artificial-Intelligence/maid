import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maid/utilities/file_manager.dart';
import 'package:maid/utilities/logger.dart';
import 'package:path/path.dart' as path;
import 'package:maid/utilities/memory_manager.dart';

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

  Future<String> saveParametersToJson(BuildContext context) async {
    try {
      parameters["name"] = name;

      String jsonString = json.encode(parameters);
      
      File? file = await FileManager.save(context, name);

      if (file == null) return "Error saving file";

      await file.writeAsString(jsonString);

      return "Model Successfully Saved to ${file.path}";
    } catch (e) {
      return "Error: $e";
    }
  }

  Future<String> loadParametersFromJson(BuildContext context) async {
    try {
      File? file = await FileManager.load(context, [".json"]);

      if (file == null) return "Error loading file";

      Logger.log("Loading parameters from $file");

      String jsonString = await file.readAsString();
      if (jsonString.isEmpty) return "Failed to load parameters";

      parameters = json.decode(jsonString);
      if (parameters.isEmpty) {
        resetAll();
        return "Failed to decode parameters";
      } else {
        name = parameters["name"] ?? "Default";
      }
    } catch (e) {
      resetAll();
      return "Error: $e";
    }

    return "Parameters Successfully Loaded";
  }

  Future<String> loadModelFile(BuildContext context) async {
    try {
      File? file = await FileManager.load(context, [".gguf"]);

      if (file == null) return "Error loading file";
      
      Logger.log("Loading model from $file");

      parameters["model_path"] = file.path;
      parameters["model_name"] = path.basename(file.path);
    } catch (e) {
      return "Error: $e";
    }

    return "Model Successfully Loaded";
  }
}
