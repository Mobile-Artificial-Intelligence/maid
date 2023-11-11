import 'package:maid/core/remote_generation.dart';
import 'package:maid/core/local_generation.dart';

class GenerationManager {
  static bool remote = false;

  static void prompt(String input) {
    if (remote) {
      RemoteGeneration.prompt(input);
    } else {
      LocalGeneration.instance.prompt(input);
    }
  }
}