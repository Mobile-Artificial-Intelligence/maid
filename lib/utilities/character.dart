import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:maid/utilities/file_manager.dart';
import 'package:maid/utilities/logger.dart';
import 'package:maid/utilities/message_manager.dart';
import 'package:maid/utilities/memory_manager.dart';
import 'package:image/image.dart';

Character character = Character();

class Character {
  File profile = File("assets/defaultResponseProfile.png");
  String name = "Maid";
  String prePrompt = "";
  String userAlias = "";
  String responseAlias = "";

  List<Map<String,dynamic>> examples = [];

  Character() {
    resetAll();
  }

  Character.fromMap(Map<String, dynamic> inputJson) {
    name = inputJson["name"] ?? "Unknown";

    if (inputJson.isEmpty) {
      resetAll();
    }

    prePrompt = inputJson["pre_prompt"] ?? "";
    userAlias = inputJson["user_alias"] ?? "";
    responseAlias = inputJson["response_alias"] ?? "";

    final length = inputJson["examples"].length ?? 0;
    examples = List<Map<String,dynamic>>.generate(length, (i) => inputJson["examples"][i]);

    Logger.log("Character created with name: ${inputJson["name"]}");
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> jsonCharacter = {};

    jsonCharacter["name"] = name;
    
    jsonCharacter["pre_prompt"] = prePrompt;
    jsonCharacter["user_alias"] = userAlias;
    jsonCharacter["response_alias"] = responseAlias;
    jsonCharacter["examples"] = examples;

    Logger.log("Character JSON created with name: $name");
    return jsonCharacter;
  }

  void resetAll() async {
    // Reset all the internal state to the defaults
    String jsonString = await rootBundle.loadString('assets/default_character.json');

    Map<String, dynamic> jsonCharacter = json.decode(jsonString);

    prePrompt = jsonCharacter["pre_prompt"] ?? "";
    userAlias = jsonCharacter["user_alias"] ?? "";
    responseAlias = jsonCharacter["response_alias"] ?? "";

    final length = jsonCharacter["examples"].length ?? 0;
    examples = List<Map<String,dynamic>>.generate(length, (i) => jsonCharacter["examples"][i]);

    MemoryManager.save();
  }

  Future<String> exportJSON(BuildContext context) async {
    try {
      // Convert the map to a JSON string
      String jsonString = json.encode(toMap());
    
      File? file = await FileManager.save(context, "$name.json");

      if (file == null) return "Error saving file";

      await file.writeAsString(jsonString);

      return "Character Successfully Saved to ${file.path}";
    } catch (e) {
      Logger.log("Error: $e");
      return "Error: $e";
    }
  }

  Future<String> importJSON(BuildContext context) async {
    try{
      File? file = await FileManager.load(context, "Load Character JSON", [".json"]);

      if (file == null) return "Error loading file";

      String jsonString = await file.readAsString();
      if (jsonString.isEmpty) return "Failed to load character";
      
      Map<String, dynamic> jsonCharacter = json.decode(jsonString);

      if (jsonCharacter.isEmpty) {
        resetAll();
        return "Failed to decode character";
      }

      name = jsonCharacter["name"] ?? "";

      prePrompt = jsonCharacter["pre_prompt"] ?? "";
      userAlias = jsonCharacter["user_alias"] ?? "";
      responseAlias = jsonCharacter["response_alias"] ?? "";

      final length = jsonCharacter["examples"].length ?? 0;
      examples = List<Map<String,dynamic>>.generate(length, (i) => jsonCharacter["examples"][i]);

      return "Character Successfully Loaded";
    } catch (e) {
      resetAll();
      Logger.log("Error: $e");
      return "Error: $e";
    }
  }

  Future<String> exportImage(BuildContext context) async {
    try {
      final image = decodePng(profile.readAsBytesSync());

      if (image == null) return "Error decoding image";

      image.textData = {
        "name": name,
        "pre_prompt": prePrompt,
        "user_alias": userAlias,
        "response_alias": responseAlias,
        "examples": json.encode(examples),
      };

      File? file = await FileManager.save(context, "$name.png");
      
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
        name = image.textData!["name"] ?? "";
        prePrompt = image.textData!["pre_prompt"] ?? "";
        userAlias = image.textData!["user_alias"] ?? "";
        responseAlias = image.textData!["response_alias"] ?? "";
        examples = List<Map<String,dynamic>>.from(json.decode(image.textData!["examples"] ?? "[]"));        
      }

      profile = file;

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