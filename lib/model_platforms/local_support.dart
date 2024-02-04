import 'package:maid/classes/parameter_support.dart';

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