import 'package:maid/classes/model_platform.dart';

class OllamaPlatform extends ModelPlatform {
  OllamaPlatform() : super(
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