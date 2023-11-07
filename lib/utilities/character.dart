import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:maid/utilities/file_manager.dart';
import 'package:maid/utilities/message_manager.dart';
import 'package:maid/utilities/memory_manager.dart';

Character character = Character();

class Character {  
  String name = "Maid";
  
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
    name = inputJson["name"] ?? "Unknown";

    if (inputJson.isEmpty) {
      resetAll();
    }

    prePromptController.text = inputJson["pre_prompt"] ?? "";
    userAliasController.text = inputJson["user_alias"] ?? "";
    responseAliasController.text = inputJson["response_alias"] ?? "";

    examplePromptControllers.clear();
    exampleResponseControllers.clear();

    if (inputJson["example"] == null) return;

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

    jsonCharacter["name"] = name;
    
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

    prePromptController.text = jsonCharacter["pre_prompt"] ?? "";
    userAliasController.text = jsonCharacter["user_alias"] ?? "";
    responseAliasController.text = jsonCharacter["response_alias"] ?? "";

    examplePromptControllers.clear();
    exampleResponseControllers.clear();

    if (jsonCharacter["example"] != null) {
      int length = jsonCharacter["example"]?.length ?? 0;
      for (var i = 0; i < length; i++) {
        String? examplePrompt = jsonCharacter["example"][i]["prompt"];
        String? exampleResponse = jsonCharacter["example"][i]["response"];
        if (examplePrompt != null && exampleResponse != null) {
          examplePromptControllers.add(TextEditingController(text: examplePrompt));
          exampleResponseControllers.add(TextEditingController(text: exampleResponse));
        }
      }
    }

    memoryManager.save();
  }

  Future<String> saveCharacterToJson(BuildContext context) async {
    try {
      Map<String, dynamic> jsonCharacter = {};

      jsonCharacter["name"] = name;

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

      // Convert the map to a JSON string
      String jsonString = json.encode(jsonCharacter);

    
      File? file = await FileManager.save(context, name);

      if (file == null) return "Error saving file";

      await file.writeAsString(jsonString);

      return "Character Successfully Saved to ${file.path}";
    } catch (e) {
      return "Error: $e";
    }
  }

  Future<String> loadCharacterFromJson(BuildContext context) async {
    try{
      File? file = await FileManager.load(context, [".json"]);

      if (file == null) return "Error loading file";

      String jsonString = await file.readAsString();
      if (jsonString.isEmpty) return "Failed to load character";
      
      Map<String, dynamic> jsonCharacter = {};

      jsonCharacter = json.decode(jsonString);
      if (jsonCharacter.isEmpty) {
        resetAll();
        return "Failed to decode character";
      }

      name = jsonCharacter["name"] ?? "";

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

    Map<String, bool> history = MessageManager.getMessages();
    if (history.isNotEmpty) {
      history.forEach((key, value) {
        if (value) {
          prePrompt += "\n${userAliasController.text.trim()} $key";
        } else {
          prePrompt += "\n${responseAliasController.text.trim()} $key";
        }
      });
    }

    return prePrompt;
  }
}