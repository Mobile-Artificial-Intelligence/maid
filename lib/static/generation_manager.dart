import 'dart:async';

import 'package:maid/core/remote_generation.dart';
import 'package:maid/core/local_generation.dart';
import 'package:maid/providers/model.dart';
import 'package:maid/models/generation_options.dart';

class GenerationManager {
  static bool busy = false;

  static void prompt(String input, GenerationOptions context,
      StreamController<String> stream) {
    if (context.apiType == ApiType.local) {
      LocalGeneration.prompt(input, context, stream);
    } else {
      RemoteGeneration.prompt(input, context, stream);
    }
  }

  static void stop() {
    LocalGeneration.stop();
  }

  static void cleanup() {
    LocalGeneration.dispose();
  }

  static ApiType checkApiRequirements(GenerationOptions context) {
    return context.apiType;
  }
}
