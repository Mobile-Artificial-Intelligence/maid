import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maid/static/file_manager.dart';
import 'package:maid/static/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Model extends ChangeNotifier {
  ApiType _apiType = ApiType.local;
  String _preset = "Default";
  Map<String, dynamic> _parameters = {};

  void init() async {
    Logger.log("Model Initialised");

    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastModel= json.decode(prefs.getString("last_model") ?? "{}");

    if (lastModel.isNotEmpty) {
      fromMap(lastModel);
      Logger.log(lastModel.toString());
    } else {
      resetAll();
    }
  }

  void setPreset(String preset) {
    _preset = preset;
    notifyListeners();
  }

  void setParameter(String key, dynamic value) {
    _parameters[key] = value;
    notifyListeners();
  }

  void setApiType(ApiType apiType) {
    _apiType = apiType;
    notifyListeners();
  }

  ApiType get apiType => _apiType;
  String get preset => _preset;
  Map<String, dynamic> get parameters => _parameters;


  void fromMap(Map<String, dynamic> inputJson) {
    if (inputJson.isEmpty) {
      resetAll();
    } else {
      _apiType = ApiType.values[inputJson["api_type"] ?? ApiType.local.index];
      _preset = inputJson["preset"] ?? "Default";
      _parameters = inputJson;

      if (_parameters["n_threads"] == null || 
          _parameters["n_threads"] > Platform.numberOfProcessors
      ) {
        _parameters["n_threads"] = Platform.numberOfProcessors;
      }
      
      Logger.log("Model created with name: ${inputJson["name"]}");
      notifyListeners();
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> jsonModel = {};

    jsonModel = _parameters;
    jsonModel["api_type"] = _apiType.index;
    jsonModel["preset"] = _preset;

    return jsonModel;
  }

  void resetAll() async {
    String jsonString = await rootBundle.loadString('assets/default_parameters.json');

    _parameters = json.decode(jsonString);

    if (_parameters["n_threads"] > Platform.numberOfProcessors) {
      _parameters["n_threads"] = Platform.numberOfProcessors;
    }

    _apiType = ApiType.local;

    notifyListeners();
  }

  Future<String> exportModelParameters(BuildContext context) async {
    try {
      _parameters["api_type"] = _apiType.index;
      _parameters["preset"] = _preset;

      String jsonString = json.encode(_parameters);
      
      File? file = await FileManager.save(context, "$_preset.json");

      if (file == null) return "Error saving file";

      await file.writeAsString(jsonString);

      return "Model Successfully Saved to ${file.path}";
    } catch (e) {
      return "Error: $e";
    }
  }

  Future<String> importModelParameters(BuildContext context) async {
    try {
      File? file = await FileManager.load(context, "Load Model JSON", [".json"]);

      if (file == null) return "Error loading file";

      Logger.log("Loading parameters from $file");

      String jsonString = await file.readAsString();
      if (jsonString.isEmpty) return "Failed to load parameters";

      _parameters = json.decode(jsonString);
      if (_parameters.isEmpty) {
        resetAll();
        return "Failed to decode parameters";
      } else {
        _apiType = ApiType.values[_parameters["api_type"] ?? ApiType.local.index];
        _preset = _parameters["preset"] ?? "Default";
      }
    } catch (e) {
      resetAll();
      return "Error: $e";
    }

    notifyListeners();
    return "Parameters Successfully Loaded";
  }

  Future<String> loadModelFile(BuildContext context) async {
    try {
      File? file = await FileManager.load(context, "Load Model File", [".gguf"]);

      if (file == null) return "Error loading file";
      
      Logger.log("Loading model from $file");

      _parameters["path"] = file.path;
    } catch (e) {
      return "Error: $e";
    }

    notifyListeners();
    return "Model Successfully Loaded";
  }
}

enum ApiType {
  none,
  local,
  openAI,
  ollama,
  custom
}