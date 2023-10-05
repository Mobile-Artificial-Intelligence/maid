import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maid/ModelFilePath.dart';
import 'package:maid/lib.dart';
import 'package:system_info_plus/system_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:maid/pages/home_page.dart';

class ParamsLlama {
  bool memory_f16 = false; // use f16 instead of f32 for memory kv
  bool random_prompt = false; // do not randomize prompt if none provided
  bool use_color = false; // use color to distinguish generations and inputs
  bool interactive = true; // interactive mode
  bool interactive_start = false; // wait for user input immediately
  bool instruct = true; // instruction mode (used for Alpaca models)
  bool ignore_eos = false; // do not stop generating after eos
  bool perplexity = false;

  TextEditingController seedController = TextEditingController()..text = "-1";
  TextEditingController n_threadsController = TextEditingController()
    ..text = "4";
  TextEditingController n_predictController = TextEditingController()
    ..text = "512";
  TextEditingController repeat_last_nController = TextEditingController()
    ..text = "64";
  TextEditingController n_partsController = TextEditingController()
    ..text = "-1";
  TextEditingController n_ctxController = TextEditingController()..text = "512";
  TextEditingController top_kController = TextEditingController()..text = "40";
  TextEditingController top_pController = TextEditingController()..text = "0.9";
  TextEditingController tempController = TextEditingController()..text = "0.80";
  TextEditingController repeat_penaltyController = TextEditingController()
    ..text = "1.10";
  TextEditingController n_batchController = TextEditingController()..text = "8";

  ParamsLlama() {
    initFromSharedPrefs();
    addListeners();
  }

  void initFromSharedPrefs() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("memory_f16")) {
      memory_f16 = prefs.getBool("memory_f16")!;
    }
    if (prefs.containsKey("random_prompt")) {
      random_prompt = prefs.getBool("random_prompt")!;
    }
    if (prefs.containsKey("use_color")) {
      use_color = prefs.getBool("use_color")!;
    }
    if (prefs.containsKey("interactive")) {
      interactive = prefs.getBool("interactive")!;
    }
    if (prefs.containsKey("interactive_start")) {
      interactive_start = prefs.getBool("interactive_start")!;
    }
    if (prefs.containsKey("instruct")) {
      instruct = prefs.getBool("instruct")!;
    }
    if (prefs.containsKey("ignore_eos")) {
      ignore_eos = prefs.getBool("ignore_eos")!;
    }
    if (prefs.containsKey("perplexity")) {
      perplexity = prefs.getBool("perplexity")!;
    }
    if (prefs.containsKey("seed")) {
      seedController.text = prefs.getString("seed")!;
    }
    if (prefs.containsKey("n_threads")) {
      n_threadsController.text = prefs.getString("n_threads")!;
    }
    if (prefs.containsKey("n_predict")) {
      n_predictController.text = prefs.getString("n_predict")!;
    }
    if (prefs.containsKey("repeat_last_n")) {
      repeat_last_nController.text = prefs.getString("repeat_last_n")!;
    }
    if (prefs.containsKey("n_parts")) {
      n_partsController.text = prefs.getString("n_parts")!;
    }
    if (prefs.containsKey("n_ctx")) {
      n_ctxController.text = prefs.getString("n_ctx")!;
    }
    if (prefs.containsKey("top_k")) {
      top_kController.text = prefs.getString("top_k")!;
    }
    if (prefs.containsKey("top_p")) {
      top_pController.text = prefs.getString("top_p")!;
    }
    if (prefs.containsKey("temp")) {
      tempController.text = prefs.getString("temp")!;
    }
    if (prefs.containsKey("repeat_penalty")) {
      repeat_penaltyController.text = prefs.getString("repeat_penalty")!;
    }
    if (prefs.containsKey("n_batch")) {
      n_batchController.text = prefs.getString("n_batch")!;
    }
  }

  void addListeners() {
    seedController.addListener(() {
      saveStringToSharedPrefs("seed", seedController.text);
    });
    n_threadsController.addListener(() {
      saveStringToSharedPrefs("n_threads", n_threadsController.text);
    });
    n_predictController.addListener(() {
      saveStringToSharedPrefs("n_predict", n_predictController.text);
    });
    repeat_last_nController.addListener(() {
      saveStringToSharedPrefs("repeat_last_n", repeat_last_nController.text);
    });
    n_partsController.addListener(() {
      saveStringToSharedPrefs("n_parts", n_partsController.text);
    });
    n_ctxController.addListener(() {
      saveStringToSharedPrefs("n_ctx", n_ctxController.text);
    });
    top_kController.addListener(() {
      saveStringToSharedPrefs("top_k", top_kController.text);
    });
    top_pController.addListener(() {
      saveStringToSharedPrefs("top_p", top_pController.text);
    });
    tempController.addListener(() {
      saveStringToSharedPrefs("temp", tempController.text);
    });
    repeat_penaltyController.addListener(() {
      saveStringToSharedPrefs("repeat_penalty", repeat_penaltyController.text);
    });
    n_batchController.addListener(() {
      saveStringToSharedPrefs("n_batch", n_batchController.text);
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
}

class ParamsLlamaValuesOnly {
  bool memory_f16;
  bool random_prompt;
  bool use_color;
  bool interactive;
  bool interactive_start;
  bool instruct;
  bool ignore_eos;
  bool perplexity;
  String seed;
  String n_threads;
  String n_predict;
  String repeat_last_n;
  String n_parts;
  String n_ctx;
  String top_k;
  String top_p;
  String temp;
  String repeat_penalty;
  String n_batch;

  ParamsLlamaValuesOnly({
    required this.memory_f16,
    required this.random_prompt,
    required this.use_color,
    required this.interactive,
    required this.interactive_start,
    required this.instruct,
    required this.ignore_eos,
    required this.perplexity,
    required this.seed,
    required this.n_threads,
    required this.n_predict,
    required this.repeat_last_n,
    required this.n_parts,
    required this.n_ctx,
    required this.top_k,
    required this.top_p,
    required this.temp,
    required this.repeat_penalty,
    required this.n_batch,
  });
}
