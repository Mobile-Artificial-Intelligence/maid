import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maid/ModelFilePath.dart';
import 'package:maid/lib.dart';
import 'package:system_info_plus/system_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:maid/llama_params.dart';

import 'package:maid/pages/home_page.dart';

class Model {
  ParamsLlama paramsLlama = ParamsLlama();
  FileState fileState = FileState.notFound;
  TextEditingController promptController = TextEditingController();
  TextEditingController reversePromptController = TextEditingController();
  bool inProgress = false;

  List<String> defaultPrePrompts = [
    'Transcript of a dialog, where the User interacts with an Assistant named Bob. Bob is helpful, kind, honest, good at writing, and never fails to answer the User\'s requests immediately and with precision.\n\n'
      'User: Hello, Bob.\n'
      'Bob: Hello. How may I help you today?\n'
      'User: Please tell me the largest city in Europe.\n'
      'Bob: Sure. The largest city in Europe is Moscow, the capital of Russia.\n'
      'User:',
    'Maid: Hello, I\'m Maid, your personal assistant. I can write, complex mails, code and even songs\n'
        'User: Hello how are you ?\n'
        'Maid: I\'m fine, thank you. How are you ?\n'
        'User: I\'m fine too, thanks.\n'
        'Maid: That\'s good to hear\n'
        'User:',
  ];

  String prePrompt = "";

  void openFile() async {
    if (fileState != FileState.notFound) {
      await ModelFilePath.detachModelFile();
      fileState = FileState.notFound;
    }
    
    fileState = FileState.opening;

    var filePath = await ModelFilePath.getFilePath(); // getting file path

    if (filePath == null) {
      print("file not found");
      fileState = FileState.notFound;
      return;
    }

    var file = File(filePath);
    if (!file.existsSync()) {
      print("file not found 2");
      fileState = FileState.notFound;
      await ModelFilePath.detachModelFile();
      return;
    }

    fileState = FileState.found;
  }

  void initDefaultPrompts() async {
    var prefs = await SharedPreferences.getInstance();
    var prePrompts = await getPrePrompts();
    if (prePrompts.isEmpty) {
      await prefs.setStringList("prePrompts", defaultPrePrompts);
      prePrompts = defaultPrePrompts;
    }
    var defaultPrePrompt = prefs.getString("defaultPrePrompt");
    if (defaultPrePrompt != null) {
      prePrompt = defaultPrePrompt;
    } else if (prePrompts.isNotEmpty) {
      prePrompt = prePrompts[0];
    }
    if (prefs.containsKey("reversePrompt")) {
      reversePromptController.text = prefs.getString("reversePrompt") ?? "";
    } else {
      reversePromptController.text = 'User:';
    }
    reversePromptController.addListener(() {
      prefs.setString("reversePrompt", reversePromptController.text);
    });
  }

  Future<List<String>> getPrePrompts() async {
    var prefs = await SharedPreferences.getInstance();
    List<String>? prePrompts = [];
    if (prefs.containsKey("prePrompts")) {
      prePrompts = prefs.getStringList("prePrompts") ?? [];
    }
    return prePrompts;
  }
}