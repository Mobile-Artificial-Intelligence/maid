import 'package:maid/classes/parameter_support.dart';

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