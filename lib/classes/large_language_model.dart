import 'package:flutter/material.dart';
import 'package:langchain/langchain.dart';

class LargeLanguageModel  extends ChangeNotifier {
  AiPlatformType get type => AiPlatformType.none;

  late String name;
  late String uri;
  late String token;

  late bool useDefault;
  late bool penalizeNewline = true;

  late int seed = 0;
  late int nKeep = 48;
  late int nPredict = 512;
  late int topK = 40;
  
  late double topP = 0.95;
  late double minP = 0.1;
  late double tfsZ = 1.0;
  late double typicalP = 1.0;
  late double temperature = 0.8;

  late int penaltyLastN = 64;
  late double penaltyRepeat = 1.1;
  late double penaltyPresent = 0.0;
  late double penaltyFreq = 0.0;

  late int mirostat = 0;
  late double mirostatTau = 5.0;
  late double mirostatEta = 0.1;
  
  late int nCtx = 512;
  late int nBatch = 512;
  late int nThread = 8;

  LargeLanguageModel({
    this.name = '',
    this.uri = '',
    this.token = '',
    this.useDefault = false,
    this.penalizeNewline = true,
    this.seed = 0,
    this.nKeep = 48,
    this.nPredict = 512,
    this.topK = 40,
    this.topP = 0.95,
    this.minP = 0.1,
    this.tfsZ = 1.0,
    this.typicalP = 1.0,
    this.temperature = 0.8,
    this.penaltyLastN = 64,
    this.penaltyRepeat = 1.1,
    this.penaltyPresent = 0.0,
    this.penaltyFreq = 0.0,
    this.mirostat = 0,
    this.mirostatTau = 5.0,
    this.mirostatEta = 0.1,
    this.nCtx = 512,
    this.nBatch = 512,
    this.nThread = 8
  });

  LargeLanguageModel.fromMap(Map<String, dynamic> json) {
    fromMap(json);
  }

  void fromMap(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    uri = json['uri'] ?? '';
    token = json['token'] ?? '';
    useDefault = json['useDefault'] ?? false;
    penalizeNewline = json['penalizeNewline'] ?? true;
    seed = json['seed'] ?? 0;
    nKeep = json['nKeep'] ?? 48;
    nPredict = json['nPredict'] ?? 512;
    topK = json['topK'] ?? 40;
    topP = json['topP'] ?? 0.95;
    minP = json['minP'] ?? 0.1;
    tfsZ = json['tfsZ'] ?? 1.0;
    typicalP = json['typicalP'] ?? 1.0;
    temperature = json['temperature'] ?? 0.8;
    penaltyLastN = json['penaltyLastN'] ?? 64;
    penaltyRepeat = json['penaltyRepeat'] ?? 1.1;
    penaltyPresent = json['penaltyPresent'] ?? 0.0;
    penaltyFreq = json['penaltyFreq'] ?? 0.0;
    mirostat = json['mirostat'] ?? 0;
    mirostatTau = json['mirostatTau'] ?? 5.0;
    mirostatEta = json['mirostatEta'] ?? 0.1;
    nCtx = json['nCtx'] ?? 512;
    nBatch = json['nBatch'] ?? 512;
    nThread = json['nThread'] ?? 8;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'uri': uri,
      'token': token,
      'useDefault': useDefault,
      'penalizeNewline': penalizeNewline,
      'seed': seed,
      'nKeep': nKeep,
      'nPredict': nPredict,
      'topK': topK,
      'topP': topP,
      'minP': minP,
      'tfsZ': tfsZ,
      'typicalP': typicalP,
      'temperature': temperature,
      'penaltyLastN': penaltyLastN,
      'penaltyRepeat': penaltyRepeat,
      'penaltyPresent': penaltyPresent,
      'penaltyFreq': penaltyFreq,
      'mirostat': mirostat,
      'mirostatTau': mirostatTau,
      'mirostatEta': mirostatEta,
      'nCtx': nCtx,
      'nBatch': nBatch,
      'nThread': nThread
    };
  }

  Stream<String> prompt(List<ChatMessage> messages) {
    throw UnimplementedError();
  }

  Future<List<String>> getOptions() {
    throw UnimplementedError();
  }

  Future<void> resetUri() {
    throw UnimplementedError();
  }
}

enum AiPlatformType { none, llamacpp, openAI, ollama, mistralAI, custom }