import 'package:maid/classes/model_platform.dart';

class LocalPlatform extends ModelPlatform {
  LocalPlatform() : super(
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
    nThreads: true
  );
}