import 'package:maid/classes/model_platform.dart';

class OpenaiPlatform extends ModelPlatform {
  OpenaiPlatform() : super(
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