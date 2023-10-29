import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

Character character = Character();

class Character {
  Map<String, dynamic> jsonCharacter = {};
  
  TextEditingController promptController = TextEditingController();
  TextEditingController prePromptController = TextEditingController();
  
  List<TextEditingController> examplePromptControllers = [];
  List<TextEditingController> exampleResponseControllers = [];

  TextEditingController userAliasController = TextEditingController();
  TextEditingController responseAliasController = TextEditingController();

  late String prePrompt;

  bool busy = false;

  Character() {
    initFromSharedPrefs();
  }

  void initFromSharedPrefs() async {
    var prefs = await SharedPreferences.getInstance();

    jsonCharacter = json.decode(prefs.getString("character") ?? "{}");

    if (jsonCharacter.isEmpty) {
      resetAll();
    }

    prePromptController.text = jsonCharacter["prePrompt"] ?? "";
    userAliasController.text = jsonCharacter["userAlias"] ?? "";
    responseAliasController.text = jsonCharacter["responseAlias"] ?? "";

    int length = jsonCharacter["examplePrompt"]?.length ?? 0;
    for (var i = 0; i < length; i++) {
      String? examplePrompt = jsonCharacter["examplePrompt_$i"];
      String? exampleResponse = jsonCharacter["exampleResponse_$i"];
      if (examplePrompt != null && exampleResponse != null) {
        examplePromptControllers.add(TextEditingController(text: examplePrompt));
        exampleResponseControllers.add(TextEditingController(text: exampleResponse));
      }
    }
  }

  void saveSharedPreferences() async {
    jsonCharacter["prePrompt"] = prePromptController.text;
    jsonCharacter["userAlias"] = userAliasController.text;
    jsonCharacter["responseAlias"] = responseAliasController.text;

    for (var i = 0; i < examplePromptControllers.length; i++) {
      jsonCharacter["examplePrompt"][i] = examplePromptControllers[i].text;
      jsonCharacter["exampleResponse"][i] = exampleResponseControllers[i].text;
    }
    
    var prefs = await SharedPreferences.getInstance();

    prefs.setString("character", json.encode(jsonCharacter));
  }

  void resetAll() async {
    // Reset all the internal state to the defaults
    String jsonString = await rootBundle.loadString('assets/default_character.json');

    jsonCharacter = json.decode(jsonString);

    prePromptController.text = jsonCharacter["prePrompt"] ?? "";
    userAliasController.text = jsonCharacter["userAlias"] ?? "";
    responseAliasController.text = jsonCharacter["responseAlias"] ?? "";

    int length = jsonCharacter["examplePrompt"]?.length ?? 0;
    for (var i = 0; i < length; i++) {
      String? examplePrompt = jsonCharacter["examplePrompt"][i];
      String? exampleResponse = jsonCharacter["exampleResponse"][i];
      if (examplePrompt != null && exampleResponse != null) {
        examplePromptControllers.add(TextEditingController(text: examplePrompt));
        exampleResponseControllers.add(TextEditingController(text: exampleResponse));
      }
    }

    // Clear values from SharedPreferences
    var prefs = await SharedPreferences.getInstance();
    prefs.clear();

    // It might be a good idea to save the default character after a reset
    saveSharedPreferences();
  }

  Future<String> saveCharacterToJson() async {
    jsonCharacter["prePrompt"] = prePromptController.text;
    jsonCharacter["userAlias"] = userAliasController.text;
    jsonCharacter["responseAlias"] = responseAliasController.text;

    for (var i = 0; i < examplePromptControllers.length; i++) {
      jsonCharacter["examplePrompt"][i] = examplePromptControllers[i].text;
      jsonCharacter["exampleResponse"][i] = exampleResponseControllers[i].text;
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
      
      jsonCharacter = json.decode(jsonString);
      if (jsonCharacter.isEmpty) {
        resetAll();
        return "Failed to decode character";
      }
    } catch (e) {
      resetAll();
      return "Error: $e";
    }

    return "Character Successfully Loaded";
  }
  
  void compilePrePrompt() {
    prePrompt = prePromptController.text.isNotEmpty ? prePromptController.text.trim() : "";
    for (var i = 0; i < examplePromptControllers.length; i++) {
      var prompt = '${userAliasController.text.trim()} ${examplePromptControllers[i].text.trim()}';
      var response = '${responseAliasController.text.trim()} ${exampleResponseControllers[i].text.trim()}';
      if (prompt.isNotEmpty && response.isNotEmpty) {
        prePrompt += "\n$prompt\n$response";
      }
    }
  }
}