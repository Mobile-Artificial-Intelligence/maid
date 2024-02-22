import 'dart:math';

import 'package:maid/providers/character.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/static/logger.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'package:maid/static/user.dart';

class GenerationOptions {
  late List<Map<String, dynamic>> _messages;
  late String? _remoteUrl;
  late PromptFormatType _promptFormat;
  late AiPlatformType _apiType;
  late String? _apiKey;
  late String _model;
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
  AiPlatformType get apiType => _apiType;
  String? get apiKey => _apiKey;
  String get model => _model;
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
    map["model"] = _model;
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
    required AiPlatform ai,
    required Character character,
    required Session session,
  }) {
    try {
      Logger.log(ai.toMap().toString());
      Logger.log(character.toMap().toString());
      Logger.log(session.toMap().toString());

      _messages = [];
      if (character.useExamples) {
        _messages.addAll(character.examples);
        _messages.addAll(session.getMessages());
      }

      _remoteUrl = ai.url;
      _promptFormat = ai.format;
      _apiType = ai.apiType;
      _apiKey = ai.apiKey;
      _model = ai.model;

      _description = replaceCaseInsensitive(
          character.description, "{{char}}", character.name);
      _description =
          replaceCaseInsensitive(_description, "<BOT>", character.name);
      _description =
          replaceCaseInsensitive(_description, "{{user}}", User.name);
      _description = replaceCaseInsensitive(_description, "<USER>", User.name);

      _personality = replaceCaseInsensitive(
          character.personality, "{{char}}", character.name);
      _personality =
          replaceCaseInsensitive(_personality, "<BOT>", character.name);
      _personality =
          replaceCaseInsensitive(_personality, "{{user}}", User.name);
      _personality = replaceCaseInsensitive(_personality, "<USER>", User.name);

      _scenario = replaceCaseInsensitive(
          character.scenario, "{{char}}", character.name);
      _scenario = replaceCaseInsensitive(_scenario, "<BOT>", character.name);
      _scenario = replaceCaseInsensitive(_scenario, "{{user}}", User.name);
      _scenario = replaceCaseInsensitive(_scenario, "<USER>", User.name);

      _system =
          replaceCaseInsensitive(character.system, "{{char}}", character.name);
      _system = replaceCaseInsensitive(_system, "<BOT>", character.name);
      _system = replaceCaseInsensitive(_system, "{{user}}", User.name);
      _system = replaceCaseInsensitive(_system, "<USER>", User.name);

      _nKeep = ai.nKeep;
      _seed = ai.randomSeed ? Random().nextInt(1000000) : ai.seed;
      _nPredict = ai.nPredict;
      _topK = ai.topK;
      _topP = ai.topP;
      _minP = ai.minP;
      _tfsZ = ai.tfsZ;
      _typicalP = ai.typicalP;
      _penaltyLastN = ai.penaltyLastN;
      _temperature = ai.temperature;
      _penaltyRepeat = ai.penaltyRepeat;
      _penaltyPresent = ai.penaltyPresent;
      _penaltyFreq = ai.penaltyFreq;
      _mirostat = ai.mirostat;
      _mirostatTau = ai.mirostatTau;
      _mirostatEta = ai.mirostatEta;
      _penalizeNewline = ai.penalizeNewline;
      _nCtx = ai.nCtx;
      _nBatch = ai.nBatch;
      _nThread = ai.nThread;
    } catch (e) {
      Logger.log(e.toString());
    }
  }
}
