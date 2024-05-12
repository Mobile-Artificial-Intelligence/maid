import 'package:flutter/material.dart';
import 'package:maid_llm/maid_llm.dart';

class LargeLanguageModel extends ChangeNotifier {
  LargeLanguageModelType get type => LargeLanguageModelType.none;

  String _name = '';
  String _uri = '';
  String _token = '';

  bool _randomSeed = true;
  bool _useDefault = false;
  bool _penalizeNewline = true;

  int _seed = 0;
  int _nKeep = 48;
  int _nPredict = 256;
  int _topK = 40;
  
  double _topP = 0.95;
  double _minP = 0.1;
  double _tfsZ = 1.0;
  double _typicalP = 1.0;
  double _temperature = 0.8;

  int _penaltyLastN = 64;
  double _penaltyRepeat = 1.1;
  double _penaltyPresent = 0.0;
  double _penaltyFreq = 0.0;

  int _mirostat = 0;
  double _mirostatTau = 5.0;
  double _mirostatEta = 0.1;
  
  int _nCtx = 512;
  int _nBatch = 512;
  int _nThread = 8;

  String get name => _name;
  String get uri => _uri;
  String get token => _token;

  Future<List<String>> get options async {
    return [];
  }

  bool get randomSeed => _randomSeed;
  bool get useDefault => _useDefault;
  bool get penalizeNewline => _penalizeNewline;

  int get seed => _seed;
  int get nKeep => _nKeep;
  int get nPredict => _nPredict;
  int get topK => _topK;

  double get topP => _topP;
  double get minP => _minP;
  double get tfsZ => _tfsZ;
  double get typicalP => _typicalP;
  double get temperature => _temperature;

  int get penaltyLastN => _penaltyLastN;
  double get penaltyRepeat => _penaltyRepeat;
  double get penaltyPresent => _penaltyPresent;
  double get penaltyFreq => _penaltyFreq;

  int get mirostat => _mirostat;
  double get mirostatTau => _mirostatTau;
  double get mirostatEta => _mirostatEta;

  int get nCtx => _nCtx;
  int get nBatch => _nBatch;
  int get nThread => _nThread;

  set name(String value) {
    _name = value;
    notifyListeners();
  }

  set uri(String value) {
    _uri = value;
    notifyListeners();
  }

  set token(String value) {
    _token = value;
    notifyListeners();
  }

  set randomSeed(bool value) {
    _randomSeed = value;
    notifyListeners();
  }

  set useDefault(bool value) {
    _useDefault = value;
    notifyListeners();
  }

  set penalizeNewline(bool value) {
    _penalizeNewline = value;
    notifyListeners();
  }

  set seed(int value) {
    _seed = value;
    notifyListeners();
  }

  set nKeep(int value) {
    _nKeep = value;
    notifyListeners();
  }

  set nPredict(int value) {
    _nPredict = value;
    notifyListeners();
  }

  set topK(int value) {
    _topK = value;
    notifyListeners();
  }

  set topP(double value) {
    _topP = value;
    notifyListeners();
  }

  set minP(double value) {
    _minP = value;
    notifyListeners();
  }

  set tfsZ(double value) {
    _tfsZ = value;
    notifyListeners();
  }

  set typicalP(double value) {
    _typicalP = value;
    notifyListeners();
  }

  set temperature(double value) {
    _temperature = value;
    notifyListeners();
  }

  set penaltyLastN(int value) {
    _penaltyLastN = value;
    notifyListeners();
  }

  set penaltyRepeat(double value) {
    _penaltyRepeat = value;
    notifyListeners();
  }

  set penaltyPresent(double value) {
    _penaltyPresent = value;
    notifyListeners();
  }

  set penaltyFreq(double value) {
    _penaltyFreq = value;
    notifyListeners();
  }

  set mirostat(int value) {
    _mirostat = value;
    notifyListeners();
  }

  set mirostatTau(double value) {
    _mirostatTau = value;
    notifyListeners();
  }

  set mirostatEta(double value) {
    _mirostatEta = value;
    notifyListeners();
  }

  set nCtx(int value) {
    _nCtx = value;
    notifyListeners();
  }

  set nBatch(int value) {
    _nBatch = value;
    notifyListeners();
  }

  set nThread(int value) {
    _nThread = value;
    notifyListeners();
  }

  LargeLanguageModel({
    VoidCallback? listener,
    String name = '',
    String uri = '',
    String token = '',
    bool randomSeed = true,
    bool useDefault = false,
    bool penalizeNewline = true,
    int seed = 0,
    int nKeep = 48,
    int nPredict = 256,
    int topK = 40,
    double topP = 0.95,
    double minP = 0.1,
    double tfsZ = 1.0,
    double typicalP = 1.0,
    double temperature = 0.8,
    int penaltyLastN = 64,
    double penaltyRepeat = 1.1,
    double penaltyPresent = 0.0,
    double penaltyFreq = 0.0,
    int mirostat = 0,
    double mirostatTau = 5.0,
    double mirostatEta = 0.1,
    int nCtx = 512,
    int nBatch = 512,
    int nThread = 8
  }) {
    if (listener != null) {
      addListener(listener);
    }

    _name = name;
    _uri = uri;
    _token = token;
    _randomSeed = randomSeed;
    _useDefault = useDefault;
    _penalizeNewline = penalizeNewline;
    _seed = seed;
    _nKeep = nKeep;
    _nPredict = nPredict;
    _topK = topK;
    _topP = topP;
    _minP = minP;
    _tfsZ = tfsZ;
    _typicalP = typicalP;
    _temperature = temperature;
    _penaltyLastN = penaltyLastN;
    _penaltyRepeat = penaltyRepeat;
    _penaltyPresent = penaltyPresent;
    _penaltyFreq = penaltyFreq;
    _mirostat = mirostat;
    _mirostatTau = mirostatTau;
    _mirostatEta = mirostatEta;
    _nCtx = nCtx;
    _nBatch = nBatch;
    _nThread = nThread;
  }

  LargeLanguageModel.fromMap(VoidCallback listener, Map<String, dynamic> json) {
    fromMap(json);
  }

  void fromMap(Map<String, dynamic> json) {
    _name = json['name'] ?? '';
    _uri = json['uri'] ?? '';
    _token = json['token'] ?? '';
    _randomSeed = json['randomSeed'] ?? true;
    _useDefault = json['useDefault'] ?? false;
    _penalizeNewline = json['penalizeNewline'] ?? true;
    _seed = json['seed'] ?? 0;
    _nKeep = json['nKeep'] ?? 48;
    _nPredict = json['nPredict'] ?? 256;
    _topK = json['topK'] ?? 40;
    _topP = json['topP'] ?? 0.95;
    _minP = json['minP'] ?? 0.1;
    _tfsZ = json['tfsZ'] ?? 1.0;
    _typicalP = json['typicalP'] ?? 1.0;
    _temperature = json['temperature'] ?? 0.8;
    _penaltyLastN = json['penaltyLastN'] ?? 64;
    _penaltyRepeat = json['penaltyRepeat'] ?? 1.1;
    _penaltyPresent = json['penaltyPresent'] ?? 0.0;
    _penaltyFreq = json['penaltyFreq'] ?? 0.0;
    _mirostat = json['mirostat'] ?? 0;
    _mirostatTau = json['mirostatTau'] ?? 5.0;
    _mirostatEta = json['mirostatEta'] ?? 0.1;
    _nCtx = json['nCtx'] ?? 512;
    _nBatch = json['nBatch'] ?? 512;
    _nThread = json['nThread'] ?? 8;

    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    return {
      'name': _name,
      'uri': _uri,
      'token': _token,
      'randomSeed': _randomSeed,
      'useDefault': _useDefault,
      'penalizeNewline': _penalizeNewline,
      'seed': _seed,
      'nKeep': _nKeep,
      'nPredict': _nPredict,
      'topK': _topK,
      'topP': _topP,
      'minP': _minP,
      'tfsZ': _tfsZ,
      'typicalP': _typicalP,
      'temperature': _temperature,
      'penaltyLastN': _penaltyLastN,
      'penaltyRepeat': _penaltyRepeat,
      'penaltyPresent': _penaltyPresent,
      'penaltyFreq': _penaltyFreq,
      'mirostat': _mirostat,
      'mirostatTau': _mirostatTau,
      'mirostatEta': _mirostatEta,
      'nCtx': _nCtx,
      'nBatch': _nBatch,
      'nThread': _nThread
    };
  }

  List<String> get missingRequirements {
    List<String> missing = [];

    if (_name.isEmpty) {
      missing.add('- A model option is required for prompting.\n');
    } 
    
    if (_uri.isEmpty) {
      missing.add('- A compatible URL is required for prompting.\n');
    }

    if (_token.isEmpty) {
      missing.add('- An authentication token is required for prompting.\n');
    } 
    
    return missing;
  }

  Stream<String> prompt(List<ChatNode> messages) {
    throw UnimplementedError();
  }

  Future<void> resetUri() {
    throw UnimplementedError();
  }

  void reset() {
    fromMap({});
  }

  void save() {
    throw UnimplementedError();
  }
}

enum LargeLanguageModelType { none, llamacpp, openAI, ollama, mistralAI, gemini }