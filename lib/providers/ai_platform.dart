import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maid/static/generation_manager.dart';
import 'package:maid/static/file_manager.dart';
import 'package:maid/static/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maid_llm/maid_llm.dart';

class AiPlatform extends ChangeNotifier {
  PromptFormat _promptFormat = PromptFormat.alpaca;
  AiPlatformType _apiType = AiPlatformType.llamacpp;
  String _apiKey = "";
  String _url = "";
  String _model = "";

  bool _randomSeed = true;
  bool _useDefault = true;

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

  void notify() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt("api_type", _apiType.index);
    });

    notifyListeners();
  }

  void init() async {
    Logger.log("Model Initialised");

    final prefs = await SharedPreferences.getInstance();

    final apiIndex = prefs.getInt("api_type") ?? AiPlatformType.llamacpp.index;

    _apiType = AiPlatformType.values[apiIndex];

    switch (_apiType) {
      case AiPlatformType.llamacpp:
        switchLlamaCpp();
        break;
      case AiPlatformType.openAI:
        switchOpenAI();
        break;
      case AiPlatformType.ollama:
        switchOllama();
        break;
      case AiPlatformType.mistralAI:
        switchMistralAI();
        break;
      default:
        reset();
    }
  }

  Future<String> resetUrl() async {
    switch (_apiType) {
      case AiPlatformType.ollama:
        _url = await GenerationManager.getOllamaUrl();
      case AiPlatformType.openAI:
        _url = "https://api.openai.com/v1/";
      case AiPlatformType.mistralAI:
        _url = "https://api.mistral.ai/v1/";
      default:
        _url = "";
    }

    notifyListeners();
    return _url;
  }

  void switchLlamaCpp() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastLlamaCpp =
        json.decode(prefs.getString("llama_cpp_model") ?? "{}");
    
    if (lastLlamaCpp.isNotEmpty) {
      fromMap(lastLlamaCpp);
      Logger.log(lastLlamaCpp.toString());
    } 
    else {
      reset();
    }

    notify();
  }

  void switchOpenAI() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastOpenAI =
        json.decode(prefs.getString("open_ai_model") ?? "{}");
    
    if (lastOpenAI.isNotEmpty) {
      fromMap(lastOpenAI);
      Logger.log(lastOpenAI.toString());
    } 
    else {
      reset();
      await resetUrl();
    }

    notify();
  }

  void switchOllama() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastOllama =
        json.decode(prefs.getString("ollama_model") ?? "{}");
    
    if (lastOllama.isNotEmpty) {
      fromMap(lastOllama);
      Logger.log(lastOllama.toString());
    } 
    else {
      reset();
      await resetUrl();
    }

    notify();
  }

  void switchMistralAI() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastMistralAI =
        json.decode(prefs.getString("mistral_ai_model") ?? "{}");
    
    if (lastMistralAI.isNotEmpty) {
      fromMap(lastMistralAI);
      Logger.log(lastMistralAI.toString());
    } 
    else {
      reset();
      await resetUrl();
    }

    notify();
  }

  set apiType(AiPlatformType apiType) {
    Logger.log("Switching to $apiType");

    switch (apiType) {
      case AiPlatformType.llamacpp:
        switchLlamaCpp();
        break;
      case AiPlatformType.openAI:
        switchOpenAI();
        break;
      case AiPlatformType.ollama:
        switchOllama();
        break;
      case AiPlatformType.mistralAI:
        switchMistralAI();
        break;
      default:
        reset();
    }

    _apiType = apiType;

    notifyListeners();
  }

  set promptFormat(PromptFormat promptFormat) {
    _promptFormat = promptFormat;
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

  set useDefault(bool useDefault) {
    _useDefault = useDefault;
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

  PromptFormat get promptFormat => _promptFormat;
  AiPlatformType get apiType => _apiType;
  String get apiKey => _apiKey;
  String get url => _url;
  String get model => _model;
  bool get randomSeed => _randomSeed;
  bool get useDefault => _useDefault;
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

  Future<List<String>> getOptions() async {
    if (_url.isEmpty) {
      await resetUrl();
    }

    return GenerationManager.getOptions(this);
  }

  void fromMap(Map<String, dynamic> inputJson) {
    if (inputJson.isEmpty) {
      reset();
    } else {
      _promptFormat = PromptFormat.values[inputJson["prompt_promptFormat"] ?? _promptFormat.index];
      _apiType = AiPlatformType.values[inputJson["api_type"] ?? _apiType.index];
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

  void reset() {
    rootBundle.loadString('assets/default_parameters.json').then((jsonString) {
      Map<String, dynamic> assetJson = json.decode(jsonString);

      fromMap(assetJson);

      notifyListeners();
    });
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

enum AiPlatformType { llamacpp, openAI, ollama, mistralAI, custom }
