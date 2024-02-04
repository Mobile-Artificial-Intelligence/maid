abstract class ModelPlatform {
  final bool _responseFormat;
  final bool _nKeep;
  final bool _nPredict;
  final bool _topK;
  final bool _topP;
  final bool _tfsZ;
  final bool _typicalP;
  final bool _repeatLastN;
  final bool _repeatPenalty;
  final bool _presencePenalty;
  final bool _frequencyPenalty;
  final bool _stop;
  final bool _mirostat;
  final bool _mirostatTau;
  final bool _mirostatEta;
  final bool _penalizeNewline;
  final bool _nCtx;
  final bool _nBatch;
  final bool _nGqa;
  final bool _nGpu;
  final bool _nThreads;
  final bool _mainGpu;
  final bool _lowVram;
  final bool _logitsAll;
  final bool _vocabOnly;
  final bool _useMmap;
  final bool _useMlock;
  final bool _embeddingOnly;
  final bool _ropeFrequencyBase;
  final bool _ropeFrequencyScale;
  final bool _maxTokens;
  final bool _logitsBias;

  ModelPlatform(
    this._responseFormat,
    this._nKeep,
    this._nPredict,
    this._topK,
    this._topP,
    this._tfsZ,
    this._typicalP,
    this._repeatLastN,
    this._repeatPenalty,
    this._presencePenalty,
    this._frequencyPenalty,
    this._stop,
    this._mirostat,
    this._mirostatTau,
    this._mirostatEta,
    this._penalizeNewline,
    this._nCtx,
    this._nBatch,
    this._nGqa,
    this._nGpu,
    this._nThreads,
    this._mainGpu,
    this._lowVram,
    this._logitsAll,
    this._vocabOnly,
    this._useMmap,
    this._useMlock,
    this._embeddingOnly,
    this._ropeFrequencyBase,
    this._ropeFrequencyScale,
    this._maxTokens,
    this._logitsBias
  );

  bool get hasResponseFormat => _responseFormat;
  bool get hasNKeep => _nKeep;
  bool get hasNPredict => _nPredict;
  bool get hasTopK => _topK;
  bool get hasTopP => _topP;
  bool get hasTfsZ => _tfsZ;
  bool get hasTypicalP => _typicalP;
  bool get hasRepeatLastN => _repeatLastN;
  bool get hasRepeatPenalty => _repeatPenalty;
  bool get hasPresencePenalty => _presencePenalty;
  bool get hasFrequencyPenalty => _frequencyPenalty;
  bool get hasStop => _stop;
  bool get hasMirostat => _mirostat;
  bool get hasMirostatTau => _mirostatTau;
  bool get hasMirostatEta => _mirostatEta;
  bool get hasPenalizeNewline => _penalizeNewline;
  bool get hasNCtx => _nCtx;
  bool get hasNBatch => _nBatch;
  bool get hasNGqa => _nGqa;
  bool get hasNGpu => _nGpu;
  bool get hasNThreads => _nThreads;
  bool get hasMainGpu => _mainGpu;
  bool get hasLowVram => _lowVram;
  bool get hasLogitsAll => _logitsAll;
  bool get hasVocabOnly => _vocabOnly;
  bool get hasUseMmap => _useMmap;
  bool get hasUseMlock => _useMlock;
  bool get hasEmbeddingOnly => _embeddingOnly;
  bool get hasRopeFrequencyBase => _ropeFrequencyBase;
  bool get hasRopeFrequencyScale => _ropeFrequencyScale;
  bool get hasMaxTokens => _maxTokens;
  bool get hasLogitsBias => _logitsBias;
}