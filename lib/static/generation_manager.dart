import 'package:maid/core/remote_generation.dart';
import 'package:maid/core/local_generation.dart';
import 'package:maid/types/character.dart';
import 'package:maid/types/model.dart';

class GenerationManager {
  static bool remote = false;

  static void prompt(String input, Model model, Character character) {
    if (remote) {
      RemoteGeneration.prompt(input, model, character);
    } else {
      LocalGeneration.instance.prompt(input, model, character);
    }
  }

  static void cleanup() {
    LocalGeneration.instance.cleanup();
  }
}