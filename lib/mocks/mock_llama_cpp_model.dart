import 'dart:ui';

import 'package:maid/classes/large_language_model.dart';

// This model is to mock the LlamaCPP model, which is not available on the web platform
class LlamaCppModel extends LargeLanguageModel {
  @override
  LargeLanguageModelType get type => LargeLanguageModelType.llamacpp;

  @override
  List<String> get missingRequirements {    
    return ['Llama.cpp is unsupported on web.'];
  }

  LlamaCppModel({
    super.listener, 
    super.name,
    super.uri,
    super.useDefault,
    super.penalizeNewline,
    super.seed,
    super.nKeep,
    super.nPredict,
    super.topK,
    super.topP,
    super.minP,
    super.tfsZ,
    super.typicalP,
    super.temperature,
    super.penaltyLastN,
    super.penaltyRepeat,
    super.penaltyPresent,
    super.penaltyFreq,
    super.mirostat,
    super.mirostatTau,
    super.mirostatEta,
    super.nCtx,
    super.nBatch,
    super.nThread,
  });

  LlamaCppModel.fromMap(VoidCallback listener, Map<String, dynamic> json) {
    addListener(listener);
    fromMap(json);
  }

  void stop() {
    throw UnimplementedError();
  }
}