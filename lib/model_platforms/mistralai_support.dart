import 'package:maid/classes/parameter_support.dart';

class MistralAiSupport extends ParameterSupport {
  MistralAiSupport() : super(
    temperture: true,
    topP: true,
    maxTokens: true
  );
}