import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maid/lib.dart';
import 'package:system_info_plus/system_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:maid/pages/home_page.dart';

class Model {
  bool inProgress = false;
  bool memory_f16 = false; // use f16 instead of f32 for memory kv
  bool random_prompt = false; // do not randomize prompt if none provided
  bool use_color = false; // use color to distinguish generations and inputs
  bool interactive = true; // interactive mode
  bool interactive_start = false; // wait for user input immediately
  bool instruct = true; // instruction mode (used for Alpaca models)
  bool ignore_eos = false; // do not stop generating after eos
  bool perplexity = false;

  TextEditingController promptController = TextEditingController();
  TextEditingController reversePromptController = TextEditingController();
  TextEditingController prePromptController = TextEditingController();
  TextEditingController seedController = TextEditingController()..text = "-1";
  TextEditingController n_threadsController = TextEditingController()..text = "4";
  TextEditingController n_predictController = TextEditingController()..text = "512";
  TextEditingController repeat_last_nController = TextEditingController()..text = "64";
  TextEditingController n_partsController = TextEditingController()..text = "-1";
  TextEditingController n_ctxController = TextEditingController()..text = "512";
  TextEditingController top_kController = TextEditingController()..text = "40";
  TextEditingController top_pController = TextEditingController()..text = "0.9";
  TextEditingController tempController = TextEditingController()..text = "0.80";
  TextEditingController repeat_penaltyController = TextEditingController()..text = "1.10";
  TextEditingController n_batchController = TextEditingController()..text = "8";

  var boolKeys = {};
  var stringKeys = {};

  FileState fileState = FileState.notFound;

  Model() {
    initKeys();
    initFromSharedPrefs();
    addListeners();
  }

  void initKeys() {
    // Map for boolean values
    boolKeys = {
      "memory_f16": memory_f16,
      "random_prompt": random_prompt,
      "use_color": use_color,
      "interactive": interactive,
      "interactive_start": interactive_start,
      "instruct": instruct,
      "ignore_eos": ignore_eos,
      "perplexity": perplexity
    };

    // Map for string values
    stringKeys = {
      "pre_prompt": prePromptController,
      "seed": seedController,
      "n_threads": n_threadsController,
      "n_predict": n_predictController,
      "repeat_last_n": repeat_last_nController,
      "n_parts": n_partsController,
      "n_ctx": n_ctxController,
      "top_k": top_kController,
      "top_p": top_pController,
      "temp": tempController,
      "repeat_penalty": repeat_penaltyController,
      "n_batch": n_batchController
    };
  }

  void initFromSharedPrefs() async {
    var prefs = await SharedPreferences.getInstance();

    // Load boolean values from prefs
    for (var key in boolKeys.keys) {
      if (prefs.containsKey(key)) {
        boolKeys[key] = prefs.getBool(key)!;
      }
    }

    // Load string values from prefs
    for (var key in stringKeys.keys) {
      if (prefs.containsKey(key)) {
        stringKeys[key]!.text = prefs.getString(key)!;
      }
    }
  }

  void addListeners() {
    stringKeys.forEach((key, controller) {
      controller.addListener(() {
        saveStringToSharedPrefs(key, controller.text);
      });
    });
  }

  void saveStringToSharedPrefs(String s, String text) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(s, text);
    });
  }

  void saveBoolToSharedPrefs(String s, bool value) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(s, value);
    });
  }

  void resetAll(void Function(VoidCallback fn) setState) async {
    setState(() {
      memory_f16 = false;
      random_prompt = false;
      use_color = false;
      interactive = true;
      interactive_start = false;
      instruct = true;
      ignore_eos = false;
      perplexity = false;
    });

    prePromptController.text = "";
    seedController.text = "-1";
    n_threadsController.text = "4";
    n_predictController.text = "512";
    repeat_last_nController.text = "64";
    n_partsController.text = "-1";
    n_ctxController.text = "512";
    top_kController.text = "40";
    top_pController.text = "0.9";
    tempController.text = "0.80";
    repeat_penaltyController.text = "1.10";
    n_batchController.text = "8";
    saveAll();
  }

  void saveAll() {
    saveBoolToSharedPrefs("memory_f16", memory_f16);
    saveBoolToSharedPrefs("random_prompt", random_prompt);
    saveBoolToSharedPrefs("use_color", use_color);
    saveBoolToSharedPrefs("interactive", interactive);
    saveBoolToSharedPrefs("interactive_start", interactive_start);
    saveBoolToSharedPrefs("instruct", instruct);
    saveBoolToSharedPrefs("ignore_eos", ignore_eos);
    saveBoolToSharedPrefs("perplexity", perplexity);
    saveStringToSharedPrefs("pre_prompt", prePromptController.text);
    saveStringToSharedPrefs("seed", seedController.text);
    saveStringToSharedPrefs("n_threads", n_threadsController.text);
    saveStringToSharedPrefs("n_predict", n_predictController.text);
    saveStringToSharedPrefs("repeat_last_n", repeat_last_nController.text);
    saveStringToSharedPrefs("n_parts", n_partsController.text);
    saveStringToSharedPrefs("n_ctx", n_ctxController.text);
    saveStringToSharedPrefs("top_k", top_kController.text);
    saveStringToSharedPrefs("top_p", top_pController.text);
    saveStringToSharedPrefs("temp", tempController.text);
    saveStringToSharedPrefs("repeat_penalty", repeat_penaltyController.text);
    saveStringToSharedPrefs("n_batch", n_batchController.text);
  }

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
}