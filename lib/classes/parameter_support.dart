abstract class ParameterSupport {
  final bool _temperture;
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

  ParameterSupport({
    bool? temperture,
    bool? responseFormat,
    bool? nKeep,
    bool? nPredict,
    bool? topK,
    bool? topP,
    bool? tfsZ,
    bool? typicalP,
    bool? repeatLastN,
    bool? repeatPenalty,
    bool? presencePenalty,
    bool? frequencyPenalty,
    bool? stop,
    bool? mirostat,
    bool? mirostatTau,
    bool? mirostatEta,
    bool? penalizeNewline,
    bool? nCtx,
    bool? nBatch,
    bool? nGqa,
    bool? nGpu,
    bool? nThreads,
    bool? mainGpu,
    bool? lowVram,
    bool? logitsAll,
    bool? vocabOnly,
    bool? useMmap,
    bool? useMlock,
    bool? embeddingOnly,
    bool? ropeFrequencyBase,
    bool? ropeFrequencyScale,
    bool? maxTokens,
    bool? logitsBias,
  }) : _temperture = temperture ?? false,
       _responseFormat = responseFormat ?? false,
       _nKeep = nKeep ?? false,
       _nPredict = nPredict ?? false,
       _topK = topK ?? false,
       _topP = topP ?? false,
       _tfsZ = tfsZ ?? false,
       _typicalP = typicalP ?? false,
       _repeatLastN = repeatLastN ?? false,
       _repeatPenalty = repeatPenalty ?? false,
       _presencePenalty = presencePenalty ?? false,
       _frequencyPenalty = frequencyPenalty ?? false,
       _stop = stop ?? false,
       _mirostat = mirostat ?? false,
       _mirostatTau = mirostatTau ?? false,
       _mirostatEta = mirostatEta ?? false,
       _penalizeNewline = penalizeNewline ?? false,
       _nCtx = nCtx ?? false,
       _nBatch = nBatch ?? false,
       _nGqa = nGqa ?? false,
       _nGpu = nGpu ?? false,
       _nThreads = nThreads ?? false,
       _mainGpu = mainGpu ?? false,
       _lowVram = lowVram ?? false,
       _logitsAll = logitsAll ?? false,
       _vocabOnly = vocabOnly ?? false,
       _useMmap = useMmap ?? false,
       _useMlock = useMlock ?? false,
       _embeddingOnly = embeddingOnly ?? false,
       _ropeFrequencyBase = ropeFrequencyBase ?? false,
       _ropeFrequencyScale = ropeFrequencyScale ?? false,
       _maxTokens = maxTokens ?? false,
       _logitsBias = logitsBias ?? false;

  bool get hasTemperture => _temperture;
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

class LocalSupport extends ParameterSupport {
  LocalSupport() : super(
    temperture: true,
    topK: true,
    topP: true,
    tfsZ: true,
    typicalP: true,
    repeatLastN: true,
    repeatPenalty: true,
    presencePenalty: true,
    frequencyPenalty: true,
    mirostat: true,
    mirostatTau: true,
    mirostatEta: true,
    penalizeNewline: true,
    nCtx: true,
    nBatch: true,
    mainGpu: true,
    logitsAll: true,
    vocabOnly: true,
    useMmap: true,
    useMlock: true,
    embeddingOnly: true,
    ropeFrequencyBase: true,
    ropeFrequencyScale: true,
    nThreads: true,
    logitsBias: true
  );
}

class OllamaSupport extends ParameterSupport {
  OllamaSupport() : super(
    temperture: true,
    responseFormat: true,
    nKeep: true,
    nPredict: true,
    topK: true,
    topP: true,
    tfsZ: true,
    typicalP: true,
    repeatLastN: true,
    repeatPenalty: true,
    presencePenalty: true,
    frequencyPenalty: true,
    stop: true,
    mirostat: true,
    mirostatTau: true,
    mirostatEta: true,
    penalizeNewline: true,
    nCtx: true,
    nBatch: true,
    nGqa: true,
    nGpu: true,
    mainGpu: true,
    lowVram: true,
    logitsAll: true,
    vocabOnly: true,
    useMmap: true,
    useMlock: true,
    embeddingOnly: true,
    ropeFrequencyBase: true,
    ropeFrequencyScale: true,
    nThreads: true,
    maxTokens: true
  );
}

class OpenAiSupport extends ParameterSupport {
  OpenAiSupport() : super(
    temperture: true,
    responseFormat: true,
    topP: true,
    presencePenalty: true,
    frequencyPenalty: true,
    stop: true,
    maxTokens: true,
    logitsBias: true
  );
}

class MistralAiSupport extends ParameterSupport {
  MistralAiSupport() : super(
    temperture: true,
    topP: true,
    maxTokens: true
  );
}