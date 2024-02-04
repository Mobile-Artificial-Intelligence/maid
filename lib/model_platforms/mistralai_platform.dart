import 'package:maid/classes/model_platform.dart';

class MistralaiPlatform extends ModelPlatform {
  MistralaiPlatform() : super(
    temperture: true,
    topP: true,
    maxTokens: true
  );
}