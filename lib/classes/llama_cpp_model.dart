import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:maid/classes/large_language_model.dart';
import 'package:maid/static/logger.dart';
import 'package:maid_llm/maid_llm.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LlamaCppModel extends LargeLanguageModel {
  @override
  LargeLanguageModelType get type => LargeLanguageModelType.llamacpp;

  MaidLLM? _maidLLM;

  PromptFormat _promptFormat = PromptFormat.alpaca;

  PromptFormat get promptFormat => _promptFormat;

  set promptFormat(PromptFormat value) {
    _promptFormat = value;
    notifyListeners();
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
    PromptFormat promptFormat = PromptFormat.alpaca
  }) {
    if (uri.isNotEmpty && Directory(uri).existsSync()) {
      _maidLLM = MaidLLM(toGptParams(), log: Logger.log);
    }

    _promptFormat = promptFormat;
  }

  LlamaCppModel.fromMap(VoidCallback listener, Map<String, dynamic> json) {
    addListener(listener);
    fromMap(json);
  }

  @override
  void fromMap(Map<String, dynamic> json) {
    super.fromMap(json);
    _promptFormat = PromptFormat.values[json['promptFormat'] ?? PromptFormat.alpaca.index];
    notifyListeners();
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'promptFormat': promptFormat.index
    };
  }

  GptParams toGptParams() {
    if (uri.isEmpty) {
      throw Exception("Model URI is empty");
    }

    if (useDefault) {
      GptParams gptParams = GptParams();
      gptParams.model = uri;
      return gptParams;
    }

    SamplingParams samplingParams = SamplingParams();
    samplingParams.temp = temperature;
    samplingParams.topK = topK;
    samplingParams.topP = topP;
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

    GptParams gptParams = GptParams();
    gptParams.seed = seed != 0 ? seed : Random().nextInt(1000000);
    gptParams.nThreads = nThread;
    gptParams.nThreadsBatch = nThread;
    gptParams.nPredict = nPredict;
    gptParams.nCtx = nCtx;
    gptParams.nBatch = nBatch;
    gptParams.nKeep = nKeep;
    gptParams.sparams = samplingParams;
    gptParams.model = uri;
    gptParams.instruct = promptFormat == PromptFormat.alpaca;
    gptParams.chatml = promptFormat == PromptFormat.chatml;

    return gptParams;
  }

  Future<String> loadModel(BuildContext context) async {
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
      return "Error: $e";
    }

    return "Model Successfully Loaded";
  }

  @override
  Stream<String> prompt(List<ChatNode> messages) {
    try {
      _maidLLM ??= MaidLLM(toGptParams(), log: Logger.log);

      return _maidLLM!.prompt(messages);
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
  Future<void> updateOptions() async {
    options = [];
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