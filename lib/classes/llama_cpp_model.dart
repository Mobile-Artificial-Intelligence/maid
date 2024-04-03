import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:maid/classes/large_language_model.dart';
import 'package:maid/static/file_manager.dart';
import 'package:maid/static/logger.dart';
import 'package:maid_llm/maid_llm.dart';

class LlamaCppModel extends LargeLanguageModel {
  @override
  AiPlatformType get type => AiPlatformType.llamacpp;

  MaidLLM? _maidLLM;

  late PromptFormat promptFormat;
  
  LlamaCppModel({
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
    this.promptFormat = PromptFormat.alpaca
  }) {
    if (uri.isNotEmpty && Directory(uri).existsSync()) {
      _maidLLM = MaidLLM(toGptParams(), log: Logger.log);
    }
  }

  LlamaCppModel.fromMap(Map<String, dynamic> json) {
    fromMap(json);
  }

  @override
  void fromMap(Map<String, dynamic> json) {
    super.fromMap(json);
    promptFormat = PromptFormat.values[json['promptFormat']];
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'promptFormat': promptFormat.index
    };
  }

  GptParams toGptParams() {
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
      File? file =
          await FileManager.load(context, "Load Model File", [".gguf"]);

      if (file == null) return "Error loading file";

      Logger.log("Loading model from $file");

      name = file.path.split('/').last;
      uri = file.path;
      _maidLLM = MaidLLM(toGptParams(), log: Logger.log);
    } catch (e) {
      return "Error: $e";
    }

    return "Model Successfully Loaded";
  }

  @override
  Stream<String> prompt(List<ChatMessage> messages) {
    _maidLLM ??= MaidLLM(toGptParams(), log: Logger.log);

    return _maidLLM!.prompt(messages);
  }

  void reset() {
    _maidLLM?.reset(toGptParams());
  }

  void stop() async {
    await _maidLLM?.stop();
  }
  
  @override
  Future<List<String>> getOptions() async {
    return [];
  }
  
  @override
  Future<void> resetUri() async {
    uri = '';
  }
}