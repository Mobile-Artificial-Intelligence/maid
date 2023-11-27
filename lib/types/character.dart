import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:maid/static/file_manager.dart';
import 'package:maid/static/logger.dart';
import 'package:maid/static/message_manager.dart';
import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';

class Character extends ChangeNotifier {
  File profile = File("/assets/default_profile.png");
  String _name = "Maid";
  String prePrompt = "";
  String userAlias = "";
  String responseAlias = "";

  List<Map<String,dynamic>> examples = [];

  Character() {
    _initProfile().then((value) => resetAll());
  }

  void fromMap(Map<String, dynamic> inputJson) {
    if (inputJson["profile"] != null) {
      profile = File(inputJson["profile"]);
    } else {
      _initProfile().then((value) => resetAll());
    }
    
    _name = inputJson["name"] ?? "Unknown";

    if (inputJson.isEmpty) {
      resetAll();
    }

    prePrompt = inputJson["pre_prompt"] ?? "";
    userAlias = inputJson["user_alias"] ?? "";
    responseAlias = inputJson["response_alias"] ?? "";

    if (inputJson["examples"] != null) {
      final length = inputJson["examples"].length ?? 0;
      examples = List<Map<String,dynamic>>.generate(length, (i) => inputJson["examples"][i]);
    }

    Logger.log("Character created with name: ${inputJson["name"]}");
    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> jsonCharacter = {};

    jsonCharacter["name"] = _name;
    
    jsonCharacter["pre_prompt"] = prePrompt;
    jsonCharacter["user_alias"] = userAlias;
    jsonCharacter["response_alias"] = responseAlias;
    jsonCharacter["examples"] = examples;

    return jsonCharacter;
  }

  void setName(String newName) {
    _name = newName;
    notifyListeners();
  }

  String get name => _name;

  Future<void> _initProfile() async {
    Directory docDir = await getApplicationDocumentsDirectory();
    String filePath = '${docDir.path}/default_profile.png';

    File newProfileFile = File(filePath);
    if (!await newProfileFile.exists()) {
      ByteData data = await rootBundle.load('assets/default_profile.png');
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await newProfileFile.writeAsBytes(bytes);
    }

    profile = newProfileFile;
  }

  void resetAll() async {
    // Reset all the internal state to the defaults
    String jsonString = await rootBundle.loadString('assets/default_character.json');

    Map<String, dynamic> jsonCharacter = json.decode(jsonString);

    prePrompt = jsonCharacter["pre_prompt"] ?? "";
    userAlias = jsonCharacter["user_alias"] ?? "";
    responseAlias = jsonCharacter["response_alias"] ?? "";

    if (jsonCharacter["examples"] != null) {
      final length = jsonCharacter["examples"].length ?? 0;
      examples = List<Map<String,dynamic>>.generate(length, (i) => jsonCharacter["examples"][i]);
    }

    notifyListeners();
  }

  Future<String> exportJSON(BuildContext context) async {
    try {
      // Convert the map to a JSON string
      String jsonString = json.encode(toMap());
    
      File? file = await FileManager.save(context, "$_name.json");

      if (file == null) return "Error saving file";

      await file.writeAsString(jsonString);

      return "Character Successfully Saved to ${file.path}";
    } catch (e) {
      Logger.log("Error: $e");
      return "Error: $e";
    }
  }

  Future<String> importJSON(BuildContext context) async {
    try {
      File? file = await FileManager.load(context, "Load Character JSON", [".json"]);

      if (file == null) return "Error loading file";

      String jsonString = await file.readAsString();
      if (jsonString.isEmpty) return "Failed to load character";
      
      Map<String, dynamic> jsonCharacter = json.decode(jsonString);

      if (jsonCharacter.isEmpty) {
        resetAll();
        return "Failed to decode character";
      }

      _name = jsonCharacter["name"] ?? "";

      prePrompt = jsonCharacter["pre_prompt"] ?? "";
      userAlias = jsonCharacter["user_alias"] ?? "";
      responseAlias = jsonCharacter["response_alias"] ?? "";

      final length = jsonCharacter["examples"].length ?? 0;
      examples = List<Map<String,dynamic>>.generate(length, (i) => jsonCharacter["examples"][i]);

      notifyListeners();
      return "Character Successfully Loaded";
    } catch (e) {
      resetAll();
      Logger.log("Error: $e");
      return "Error: $e";
    }
  }

  Future<String> exportImage(BuildContext context) async {
    try {
      final image = decodeImage(profile.readAsBytesSync());

      if (image == null) return "Error decoding image";

      image.textData = {
        "name": _name,
        "pre_prompt": prePrompt,
        "user_alias": userAlias,
        "response_alias": responseAlias,
        "examples": json.encode(examples),
      };

      File? file = await FileManager.save(context, "$_name.png");
      
      if (file == null) return "Error saving file";

      await file.writeAsBytes(encodePng(image));

      return "Character Successfully Saved";
    } catch (e) {
      Logger.log("Error: $e");
      return "Error: $e";
    }
  }

  Future<String> importImage(BuildContext context) async {
    try{
      File? file = await FileManager.loadImage(context, "Load Character Image");

      if (file == null) return "Error loading file";

      final image = decodePng(file.readAsBytesSync());

      if (image != null && image.textData != null) {
        _name = image.textData!["name"] ?? "";
        prePrompt = image.textData!["pre_prompt"] ?? "";
        userAlias = image.textData!["user_alias"] ?? "";
        responseAlias = image.textData!["response_alias"] ?? "";
        examples = List<Map<String,dynamic>>.from(json.decode(image.textData!["examples"] ?? "[]"));        
      }

      profile = file;

      notifyListeners();
      return "Character Successfully Loaded";
    } catch (e) {
      resetAll();
      Logger.log("Error: $e");
      return "Error: $e";
    }
  }
  
  String getPrePrompt() {
    String result = prePrompt.isNotEmpty ? prePrompt.trim() : "";

    List<Map<String, dynamic>> history = examples;
    history += MessageManager.getMessages();
    if (history.isNotEmpty) {
      for (var i = 0; i < history.length; i++) {
        var prompt = '${userAlias.trim()} ${history[i]["prompt"].trim()}';
        var response = '${responseAlias.trim()} ${history[i]["response"].trim()}';
        if (prompt.isNotEmpty && response.isNotEmpty) {
          result += "\n$prompt\n$response";
        }
      }
    }

    return result;
  }
}