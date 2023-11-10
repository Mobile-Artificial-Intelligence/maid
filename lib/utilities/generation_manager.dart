import 'package:maid/core/hosted_generation.dart';
import 'package:maid/core/local_generation.dart';

class GenerationManager {
  static bool hosted = false;

  static void prompt(String input) {
    if (hosted) {
      HostedGeneration.prompt(input);
    } else {
      LocalGeneration.instance.prompt(input);
    }
  }
}