import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:maid/config/settings.dart';

class Character {  
  TextEditingController nameController = TextEditingController();
  
  TextEditingController promptController = TextEditingController();
  TextEditingController prePromptController = TextEditingController();
  
  List<TextEditingController> examplePromptControllers = [];
  List<TextEditingController> exampleResponseControllers = [];

  TextEditingController userAliasController = TextEditingController();
  TextEditingController responseAliasController = TextEditingController();

  bool busy = false;

  Character() {
    resetAll();
  }

  Character.fromMap(Map<String, dynamic> inputJson) {
    if (inputJson.isEmpty) {
      resetAll();
    }

    nameController.text = inputJson["name"] ?? "";

    prePromptController.text = inputJson["pre_prompt"] ?? "";
    userAliasController.text = inputJson["user_alias"] ?? "";
    responseAliasController.text = inputJson["response_alias"] ?? "";

    examplePromptControllers.clear();
    exampleResponseControllers.clear();

    int length = inputJson["example"].length ?? 0;
    for (var i = 0; i < length; i++) {
      String? examplePrompt = inputJson["example"][i]["prompt"];
      String? exampleResponse = inputJson["example"][i]["response"];
      if (examplePrompt != null && exampleResponse != null) {
        examplePromptControllers.add(TextEditingController(text: examplePrompt));
        exampleResponseControllers.add(TextEditingController(text: exampleResponse));
      }
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> jsonCharacter = {};

    jsonCharacter["name"] = nameController.text;
    
    jsonCharacter["pre_prompt"] = prePromptController.text;
    jsonCharacter["user_alias"] = userAliasController.text;
    jsonCharacter["response_alias"] = responseAliasController.text;

    // Initialize the "example" key to an empty list
    jsonCharacter["example"] = [];

    for (var i = 0; i < examplePromptControllers.length; i++) {
      // Create a map for each example and add it to the "example" list
      Map<String, String> example = {
        "prompt": examplePromptControllers[i].text,
        "response": exampleResponseControllers[i].text,
      };

      jsonCharacter["example"].add(example);
    }

    return jsonCharacter;
  } 

  void resetAll() async {
    // Reset all the internal state to the defaults
    String jsonString = await rootBundle.loadString('assets/default_character.json');

    Map<String, dynamic> jsonCharacter = json.decode(jsonString);

    nameController.text = jsonCharacter["name"] ?? "";

    prePromptController.text = jsonCharacter["pre_prompt"] ?? "";
    userAliasController.text = jsonCharacter["user_alias"] ?? "";
    responseAliasController.text = jsonCharacter["response_alias"] ?? "";

    examplePromptControllers.clear();
    exampleResponseControllers.clear();

    int length = jsonCharacter["example"]?.length ?? 0;
    for (var i = 0; i < length; i++) {
      String? examplePrompt = jsonCharacter["example"][i]["prompt"];
      String? exampleResponse = jsonCharacter["example"][i]["response"];
      if (examplePrompt != null && exampleResponse != null) {
        examplePromptControllers.add(TextEditingController(text: examplePrompt));
        exampleResponseControllers.add(TextEditingController(text: exampleResponse));
      }
    }

    settings.save();
  }

  Future<String> saveCharacterToJson() async {
    Map<String, dynamic> jsonCharacter = {};

    jsonCharacter["name"] = nameController.text;
    
    jsonCharacter["pre_prompt"] = prePromptController.text;
    jsonCharacter["user_alias"] = userAliasController.text;
    jsonCharacter["response_alias"] = responseAliasController.text;

    for (var i = 0; i < examplePromptControllers.length; i++) {
      jsonCharacter["example"][i]["prompt"] = examplePromptControllers[i].text;
      jsonCharacter["example"][i]["response"] = exampleResponseControllers[i].text;
    }

    // Convert the map to a JSON string
    String jsonString = json.encode(jsonCharacter);
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

        filePath = '${directory!.path}/maid_character.json';
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
    return "Character Successfully Saved to $filePath";
  }

  Future<String> loadCharacterFromJson() async {
    if ((Platform.isAndroid || Platform.isIOS) && 
        !(await Permission.storage.request().isGranted)) {
      return "Permission Request Failed";
    }
    
    try{
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result == null) return "No File Selected";

      File file = File(result.files.single.path!);
      String jsonString = await file.readAsString();
      if (jsonString.isEmpty) return "Failed to load character";
      
      Map<String, dynamic> jsonCharacter = {};

      jsonCharacter = json.decode(jsonString);
      if (jsonCharacter.isEmpty) {
        resetAll();
        return "Failed to decode character";
      }

      nameController.text = jsonCharacter["name"] ?? "";

      prePromptController.text = jsonCharacter["pre_prompt"] ?? "";
      userAliasController.text = jsonCharacter["user_alias"] ?? "";
      responseAliasController.text = jsonCharacter["response_alias"] ?? "";

      int length = jsonCharacter["example"]?.length ?? 0;
      for (var i = 0; i < length; i++) {
        String? examplePrompt = jsonCharacter["example"][i]["prompt"];
        String? exampleResponse = jsonCharacter["example"][i]["response"];
        if (examplePrompt != null && exampleResponse != null) {
          examplePromptControllers.add(TextEditingController(text: examplePrompt));
          exampleResponseControllers.add(TextEditingController(text: exampleResponse));
        }
      }
    } catch (e) {
      resetAll();
      return "Error: $e";
    }

    return "Character Successfully Loaded";
  }
  
  String getPrePrompt() {
    String prePrompt = prePromptController.text.isNotEmpty ? prePromptController.text.trim() : "";
    for (var i = 0; i < examplePromptControllers.length; i++) {
      var prompt = '${userAliasController.text.trim()} ${examplePromptControllers[i].text.trim()}';
      var response = '${responseAliasController.text.trim()} ${exampleResponseControllers[i].text.trim()}';
      if (prompt.isNotEmpty && response.isNotEmpty) {
        prePrompt += "\n$prompt\n$response";
      }
    }

    return prePrompt;
  }
}