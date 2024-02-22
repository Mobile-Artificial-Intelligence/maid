import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maid/static/remote_generation.dart';
import 'package:maid/static/file_manager.dart';
import 'package:maid/static/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';

class AiPlatform extends ChangeNotifier {
  PromptFormatType _promptFormat = PromptFormatType.alpaca;
  AiPlatformType _apiType = AiPlatformType.local;
  String _preset = "Default";
  String _apiKey = "";
  String _url = "";
  String _model = "";

  bool _randomSeed = true;

  int _nKeep = 48;
  int _seed = 0;
  int _nPredict = 512;
  int _topK = 40;
  double _topP = 0.95;
  double _minP = 0.1;
  double _tfsZ = 1.0;
  double _typicalP = 1.0;
  int _penaltyLastN = 64;
  double _temperature = 0.8;
  double _penaltyRepeat = 1.1;
  double _penaltyPresent = 0.0;
  double _penaltyFreq = 0.0;
  int _mirostat = 0;
  double _mirostatTau = 5.0;
  double _mirostatEta = 0.1;
  bool _penalizeNewline = true;
  int _nCtx = 512;
  int _nBatch = 512;
  int _nThread = 8;

  void newPreset() {
    final key = UniqueKey().toString();
    _preset = "New Preset $key";
    resetAll();
  }

  void notify() {
    notifyListeners();
  }

  void init() async {
    Logger.log("Model Initialised");

    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastModel =
        json.decode(prefs.getString("last_model") ?? "{}");

    if (lastModel.isNotEmpty) {
      fromMap(lastModel);
      Logger.log(lastModel.toString());
    } else {
      resetAll();
    }
  }

  set promptFormat(PromptFormatType promptFormat) {
    _promptFormat = promptFormat;
    notifyListeners();
  }

  set apiType(AiPlatformType apiType) {
    _apiType = apiType;
    notifyListeners();
  }

  set preset(String preset) {
    _preset = preset;
    notifyListeners();
  }

  set apiKey(String apiKey) {
    _apiKey = apiKey;
    notifyListeners();
  }

  set url(String url) {
    _url = url;
    notifyListeners();
  }

  set model(String model) {
    _model = model;
    notifyListeners();
  }

  set randomSeed(bool randomSeed) {
    _randomSeed = randomSeed;
    notifyListeners();
  }

  set nKeep(int nKeep) {
    _nKeep = nKeep;
    notifyListeners();
  }

  set seed(int seed) {
    _seed = seed;
    notifyListeners();
  }

  set nPredict(int nPredict) {
    _nPredict = nPredict;
    notifyListeners();
  }

  set topK(int topK) {
    _topK = topK;
    notifyListeners();
  }

  set topP(double topP) {
    _topP = topP;
    notifyListeners();
  }

  set minP(double minP) {
    _minP = minP;
    notifyListeners();
  }

  set tfsZ(double tfsZ) {
    _tfsZ = tfsZ;
    notifyListeners();
  }

  set typicalP(double typicalP) {
    _typicalP = typicalP;
    notifyListeners();
  }

  set penaltyLastN(int penaltyLastN) {
    _penaltyLastN = penaltyLastN;
    notifyListeners();
  }

  set temperature(double temperature) {
    _temperature = temperature;
    notifyListeners();
  }

  set penaltyRepeat(double penaltyRepeat) {
    _penaltyRepeat = penaltyRepeat;
    notifyListeners();
  }

  set penaltyPresent(double penaltyPresent) {
    _penaltyPresent = penaltyPresent;
    notifyListeners();
  }

  set penaltyFreq(double penaltyFreq) {
    _penaltyFreq = penaltyFreq;
    notifyListeners();
  }

  set mirostat(int mirostat) {
    _mirostat = mirostat;
    notifyListeners();
  }

  set mirostatTau(double mirostatTau) {
    _mirostatTau = mirostatTau;
    notifyListeners();
  }

  set mirostatEta(double mirostatEta) {
    _mirostatEta = mirostatEta;
    notifyListeners();
  }

  set penalizeNewline(bool penalizeNewline) {
    _penalizeNewline = penalizeNewline;
    notifyListeners();
  }

  set nCtx(int nCtx) {
    _nCtx = nCtx;
    notifyListeners();
  }

  set nBatch(int nBatch) {
    _nBatch = nBatch;
    notifyListeners();
  }

  set nThread(int nThread) {
    _nThread = nThread;
    notifyListeners();
  }

  PromptFormatType get promptFormat => _promptFormat;
  AiPlatformType get apiType => _apiType;
  String get preset => _preset;
  String get apiKey => _apiKey;
  String get url => _url;
  String get model => _model;
  bool get randomSeed => _randomSeed;
  int get nKeep => _nKeep;
  int get seed => _seed;
  int get nPredict => _nPredict;
  int get topK => _topK;
  double get topP => _topP;
  double get minP => _minP;
  double get tfsZ => _tfsZ;
  double get typicalP => _typicalP;
  int get penaltyLastN => _penaltyLastN;
  double get temperature => _temperature;
  double get penaltyRepeat => _penaltyRepeat;
  double get penaltyPresent => _penaltyPresent;
  double get penaltyFreq => _penaltyFreq;
  int get mirostat => _mirostat;
  double get mirostatTau => _mirostatTau;
  double get mirostatEta => _mirostatEta;
  bool get penalizeNewline => _penalizeNewline;
  int get nCtx => _nCtx;
  int get nBatch => _nBatch;
  int get nThread => _nThread;

  Future<List<String>> getOptions() {
    return RemoteGeneration.getOptions(this);
  }

  void fromMap(Map<String, dynamic> inputJson) {
    if (inputJson.isEmpty) {
      resetAll();
    } else {
      _promptFormat = PromptFormatType
          .values[inputJson["prompt_promptFormat"] ?? PromptFormatType.alpaca.index];
      _apiType = AiPlatformType
          .values[inputJson["api_type"] ?? AiPlatformType.local.index];
      _preset = inputJson["preset"] ?? "Default";
      _apiKey = inputJson["api_key"] ?? "";
      _url = inputJson["remote_url"] ?? "";
      _model = inputJson["model"] ?? "";
      _nKeep = inputJson["n_keep"] ?? 48;
      _seed = inputJson["seed"] ?? 0;
      _nPredict = inputJson["n_predict"] ?? 512;
      _topK = inputJson["top_k"] ?? 40;
      _topP = inputJson["top_p"] ?? 0.95;
      _minP = inputJson["min_p"] ?? 0.1;
      _tfsZ = inputJson["tfs_z"] ?? 1.0;
      _typicalP = inputJson["typical_p"] ?? 1.0;
      _penaltyLastN = inputJson["penalty_last_n"] ?? 64;
      _temperature = inputJson["temperature"] ?? 0.8;
      _penaltyRepeat = inputJson["penalty_repeat"] ?? 1.1;
      _penaltyPresent = inputJson["penalty_present"] ?? 0.0;
      _penaltyFreq = inputJson["penalty_freq"] ?? 0.0;
      _mirostat = inputJson["mirostat"] ?? 0;
      _mirostatTau = inputJson["mirostat_tau"] ?? 5.0;
      _mirostatEta = inputJson["mirostat_eta"] ?? 0.1;
      _penalizeNewline = inputJson["penalize_nl"] ?? true;
      _nCtx = inputJson["n_ctx"] ?? 512;
      _nBatch = inputJson["n_batch"] ?? 512;
      _nThread = inputJson["n_thread"] ?? 8;

      if (nThread > Platform.numberOfProcessors) {
        nThread = Platform.numberOfProcessors;
      }

      Logger.log("Model created with name: ${inputJson["name"]}");
      notifyListeners();
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> outputJson = {};

    outputJson["prompt_promptFormat"] = _promptFormat.index;
    outputJson["api_type"] = _apiType.index;
    outputJson["preset"] = _preset;
    outputJson["api_key"] = _apiKey;
    outputJson["remote_url"] = _url;
    outputJson["model"] = _model;
    outputJson["n_keep"] = _nKeep;
    outputJson["seed"] = _seed;
    outputJson["n_predict"] = _nPredict;
    outputJson["top_k"] = _topK;
    outputJson["top_p"] = _topP;
    outputJson["min_p"] = _minP;
    outputJson["tfs_z"] = _tfsZ;
    outputJson["typical_p"] = _typicalP;
    outputJson["penalty_last_n"] = _penaltyLastN;
    outputJson["temperature"] = _temperature;
    outputJson["penalty_repeat"] = _penaltyRepeat;
    outputJson["penalty_present"] = _penaltyPresent;
    outputJson["penalty_freq"] = _penaltyFreq;
    outputJson["mirostat"] = _mirostat;
    outputJson["mirostat_tau"] = _mirostatTau;
    outputJson["mirostat_eta"] = _mirostatEta;
    outputJson["penalize_nl"] = _penalizeNewline;
    outputJson["n_ctx"] = _nCtx;
    outputJson["n_batch"] = _nBatch;
    outputJson["n_thread"] = _nThread;

    return outputJson;
  }

  void resetAll() {
    rootBundle.loadString('assets/default_parameters.json').then((jsonString) {
      Map<String, dynamic> assetJson = json.decode(jsonString);

      fromMap(assetJson);

      notifyListeners();
    });
  }

  Future<String> exportModelParameters(BuildContext context) async {
    try {
      String jsonString = json.encode(toMap());

      File? file = await FileManager.save(context, "$_preset.json");

      if (file == null) return "Error saving file";

      await file.writeAsString(jsonString);

      return "Model Successfully Saved to ${file.path}";
    } catch (e) {
      return "Error: $e";
    }
  }

  Future<String> importModelParameters(BuildContext context) async {
    try {
      File? file =
          await FileManager.load(context, "Load Model JSON", [".json"]);

      if (file == null) return "Error loading file";

      Logger.log("Loading parameters from $file");

      String jsonString = await file.readAsString();
      if (jsonString.isEmpty) return "Failed to load parameters";

      Map<String, dynamic> inputJson = json.decode(jsonString);

      fromMap(inputJson);
    } catch (e) {
      resetAll();
      return "Error: $e";
    }

    notifyListeners();
    return "Parameters Successfully Loaded";
  }

  Future<String> loadModelFile(BuildContext context) async {
    try {
      File? file =
          await FileManager.load(context, "Load Model File", [".gguf"]);

      if (file == null) return "Error loading file";

      Logger.log("Loading model from $file");

      _model = file.path;
    } catch (e) {
      return "Error: $e";
    }

    notifyListeners();
    return "Model Successfully Loaded";
  }
}

enum AiPlatformType { none, local, openAI, ollama, mistralAI, custom }
