import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:maid/classes/large_language_model.dart';
import 'package:maid/static/logger.dart';
import 'package:maid_llm/maid_llm.dart';
import 'package:maid/classes/chat_node.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LlamaCppModel extends LargeLanguageModel {
  @override
  LargeLanguageModelType get type => LargeLanguageModelType.llamacpp;

  MaidLLM? _maidLLM;

  String _template = '';

  String get template => _template;

  set template(String value) {
    _template = value;
    notifyListeners();
  }

  @override
  List<String> get missingRequirements {
    List<String> missing = [];

    if (uri.isEmpty) {
      missing.add('- A path to the model file is required.\n');
    } 
    
    if (!File(uri).existsSync()) {
      missing.add('- The file provided does not exist.\n');
    }
    
    return missing;
  }
  
  LlamaCppModel({
    super.listener, 
    super.name,
    super.uri,
    super.useDefault,
    super.penalizeNewline,
    super.seed,
    super.nKeep,
    super.nPredict,
    super.topK,
    super.topP,
    super.minP,
    super.tfsZ,
    super.typicalP,
    super.temperature,
    super.penaltyLastN,
    super.penaltyRepeat,
    super.penaltyPresent,
    super.penaltyFreq,
    super.mirostat,
    super.mirostatTau,
    super.mirostatEta,
    super.nCtx,
    super.nBatch,
    super.nThread,
    String template = '',
  }) {
    if (uri.isNotEmpty && Directory(uri).existsSync()) {
      _maidLLM = MaidLLM(toGptParams(), log: Logger.log);
    }

    _template = template;
  }

  LlamaCppModel.fromMap(VoidCallback listener, Map<String, dynamic> json) {
    addListener(listener);
    fromMap(json);
  }

  @override
  void fromMap(Map<String, dynamic> json) {
    super.fromMap(json);
    _template = json['template'] ?? '';
    notifyListeners();
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'template': _template,
    };
  }

  GptParams toGptParams() {
    if (uri.isEmpty) {
      throw Exception("Model URI is empty");
    }

    if (useDefault) {
      return GptParams(uri);
    }

    SamplingParams samplingParams = SamplingParams();
    samplingParams.temp = temperature;
    samplingParams.topK = topK;
    samplingParams.topP = topP;
    samplingParams.minP = minP;
    samplingParams.tfsZ = tfsZ;
    samplingParams.typicalP = typicalP;
    samplingParams.penaltyLastN = penaltyLastN;
    samplingParams.penaltyRepeat = penaltyRepeat;
    samplingParams.penaltyFreq = penaltyFreq;
    samplingParams.penaltyPresent = penaltyPresent;
    samplingParams.mirostat = mirostat;
    samplingParams.mirostatTau = mirostatTau;
    samplingParams.mirostatEta = mirostatEta;
    samplingParams.penalizeNl = penalizeNewline;

    GptParams gptParams = GptParams(uri);
    gptParams.seed = seed != 0 ? seed : Random().nextInt(1000000);
    gptParams.nThreads = nThread;
    gptParams.nThreadsBatch = nThread;
    gptParams.nPredict = nPredict;
    gptParams.nCtx = nCtx;
    gptParams.nBatch = nBatch;
    gptParams.nKeep = nKeep;
    gptParams.sparams = samplingParams;

    return gptParams;
  }

  Future<String> loadModel() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: "Load Model File",
        type: FileType.any,
        allowMultiple: false,
        allowCompression: false
      );

      File file;
      if (result != null && result.files.isNotEmpty) {
        Logger.log("File selected: ${result.files.single.path}");
        file = File(result.files.single.path!);
      } else {
        Logger.log("No file selected");
        throw Exception("File is null");
      }

      Logger.log("Loading model from $file");

      name = file.path.split('/').last;
      uri = file.path;
      notifyListeners();
    } catch (e) {
      return e.toString();
    }

    return "Model Successfully Loaded";
  }

  @override
  Stream<String> prompt(List<ChatNode> messages) {
    try {
      _maidLLM ??= MaidLLM(toGptParams(), log: Logger.log);

      List<ChatMessage> chatMessages = [];

      for (var message in messages) {
        chatMessages.add(message.toChatMessage());
      }

      return _maidLLM!.prompt(chatMessages, _template);
    } catch (e) {
      Logger.log("Error initializing model: $e");
      return const Stream.empty();
    }
  }

  @override
  void save() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("llama_cpp_model", json.encode(toMap()));
    });
  }

  void init() {
    try {
      _maidLLM = MaidLLM(toGptParams(), log: Logger.log);

      save();
    } catch (e) {
      Logger.log("Error initializing model: $e");
    }
  }

  void stop() async {
    await _maidLLM?.stop();
  }
  
  @override
  Future<void> resetUri() async {
    uri = '';
    notifyListeners();
  }

  @override
  void reset() {
    fromMap({});
  }
}