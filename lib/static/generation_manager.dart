import 'package:maid/core/remote_generation.dart';
import 'package:maid/core/local_generation.dart';
import 'package:maid/providers/model.dart';
import 'package:maid/types/generation_context.dart';

class GenerationManager {
  static bool busy = false;

  static void prompt(
    String input, 
    GenerationContext context, 
    void Function(String) callback
  ) {
    if (context.apiType == ApiType.local) {
      RemoteGeneration.prompt(input, context, callback);
    } else {
      LocalGeneration.instance.prompt(input, context, callback);
    }
  }

  static void stop() {
    LocalGeneration.instance.stop();
  }

  static void cleanup() {
    LocalGeneration.instance.cleanup();
  }

  static ApiType checkApiRequirements(GenerationContext context) {
    return context.apiType;
  }
}
