import 'dart:math';

import 'package:maid/providers/character.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/static/logger.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';

class GenerationOptions {
  late List<Map<String, dynamic>> _messages;
  late String? _remoteUrl;
  late PromptFormatType _promptFormat;
  late ApiType _apiType;
  late String? _apiKey;
  late String? _remoteModel;
  late String? _path;
  late String _description;
  late String _personality;
  late String _scenario;
  late String _system;
  late int _nKeep;
  late int _seed;
  late int _nPredict;
  late int _topK;
  late double _topP;
  late double _minP;
  late double _tfsZ;
  late double _typicalP;
  late int _penaltyLastN;
  late double _temperature;
  late double _penaltyRepeat;
  late double _penaltyPresent;
  late double _penaltyFreq;
  late int _mirostat;
  late double _mirostatTau;
  late double _mirostatEta;
  late bool _penalizeNewline;
  late int _nCtx;
  late int _nBatch;
  late int _nThread;

  List<Map<String, dynamic>> get messages => _messages;
  String? get remoteUrl => _remoteUrl;
  PromptFormatType get promptFormat => _promptFormat;
  ApiType get apiType => _apiType;
  String? get apiKey => _apiKey;
  String? get remoteModel => _remoteModel;
  String? get path => _path;
  String get description => _description;
  String get personality => _personality;
  String get scenario => _scenario;
  String get system => _system;
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

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    map["messages"] = _messages;
    map["remote_url"] = _remoteUrl;
    map["prompt_format"] = _promptFormat.index;
    map["api_type"] = _apiType.index;
    map["api_key"] = _apiKey;
    map["remote_model"] = _remoteModel;
    map["path"] = _path;
    map["description"] = _description;
    map["personality"] = _personality;
    map["scenario"] = _scenario;
    map["system"] = _system;
    map["n_keep"] = _nKeep;
    map["seed"] = _seed;
    map["n_predict"] = _nPredict;
    map["top_k"] = _topK;
    map["top_p"] = _topP;
    map["min_p"] = _minP;
    map["tfs_z"] = _tfsZ;
    map["typical_p"] = _typicalP;
    map["penalty_last_n"] = _penaltyLastN;
    map["temperature"] = _temperature;
    map["penalty_repeat"] = _penaltyRepeat;
    map["penalty_present"] = _penaltyPresent;
    map["penalty_freq"] = _penaltyFreq;
    map["mirostat"] = _mirostat;
    map["mirostat_tau"] = _mirostatTau;
    map["mirostat_eta"] = _mirostatEta;
    map["penalize_nl"] = _penalizeNewline;
    map["n_ctx"] = _nCtx;
    map["n_batch"] = _nBatch;
    map["n_threads"] = _nThread;
    return map;
  }

  String replaceCaseInsensitive(
      String original, String from, String replaceWith) {
    // This creates a regular expression that ignores case (case-insensitive)
    RegExp exp = RegExp(RegExp.escape(from), caseSensitive: false);
    return original.replaceAll(exp, replaceWith);
  }

  GenerationOptions({
    required AiPlatform model,
    required Character character,
    required Session session,
  }) {
    try {
      Logger.log(model.toMap().toString());
      Logger.log(character.toMap().toString());
      Logger.log(session.toMap().toString());

      _messages = [];
      if (character.useExamples) {
        _messages.addAll(character.examples);
        _messages.addAll(session.getMessages());
      }

      _remoteUrl = model.parameters["remote_url"];
      _promptFormat = model.format;
      _apiType = model.apiType;
      _apiKey = model.parameters["api_key"];
      _remoteModel = model.parameters["remote_model"];
      _path = model.parameters["path"];

      _description = replaceCaseInsensitive(
          character.description, "{{char}}", character.name);
      _description =
          replaceCaseInsensitive(_description, "<BOT>", character.name);
      _description =
          replaceCaseInsensitive(_description, "{{user}}", session.userName);
      _description =
          replaceCaseInsensitive(_description, "<USER>", session.userName);

      _personality = replaceCaseInsensitive(
          character.personality, "{{char}}", character.name);
      _personality =
          replaceCaseInsensitive(_personality, "<BOT>", character.name);
      _personality =
          replaceCaseInsensitive(_personality, "{{user}}", session.userName);
      _personality =
          replaceCaseInsensitive(_personality, "<USER>", session.userName);

      _scenario = replaceCaseInsensitive(
          character.scenario, "{{char}}", character.name);
      _scenario = replaceCaseInsensitive(_scenario, "<BOT>", character.name);
      _scenario =
          replaceCaseInsensitive(_scenario, "{{user}}", session.userName);
      _scenario = replaceCaseInsensitive(_scenario, "<USER>", session.userName);

      _system =
          replaceCaseInsensitive(character.system, "{{char}}", character.name);
      _system = replaceCaseInsensitive(_system, "<BOT>", character.name);
      _system = replaceCaseInsensitive(_system, "{{user}}", session.userName);
      _system = replaceCaseInsensitive(_system, "<USER>", session.userName);

      _nKeep = model.parameters["n_keep"];
      _seed = model.parameters["random_seed"]
          ? Random().nextInt(1000000)
          : model.parameters["seed"];
      _nPredict = model.parameters["n_predict"];
      _topK = model.parameters["top_k"];
      _topP = model.parameters["top_p"];
      _minP = model.parameters["min_p"];
      _tfsZ = model.parameters["tfs_z"];
      _typicalP = model.parameters["typical_p"];
      _penaltyLastN = model.parameters["penalty_last_n"];
      _temperature = model.parameters["temperature"];
      _penaltyRepeat = model.parameters["penalty_repeat"];
      _penaltyPresent = model.parameters["penalty_present"];
      _penaltyFreq = model.parameters["penalty_freq"];
      _mirostat = model.parameters["mirostat"];
      _mirostatTau = model.parameters["mirostat_tau"];
      _mirostatEta = model.parameters["mirostat_eta"];
      _penalizeNewline = model.parameters["penalize_nl"];
      _nCtx = model.parameters["n_ctx"];
      _nBatch = model.parameters["n_batch"];
      _nThread = model.parameters["n_threads"];
    } catch (e) {
      Logger.log(e.toString());
    }
  }
}
