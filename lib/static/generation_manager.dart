import 'dart:async';

import 'package:maid/core/remote_generation.dart';
import 'package:maid/core/local_generation.dart';
import 'package:maid/providers/model.dart';
import 'package:maid/models/generation_options.dart';

class GenerationManager {
  static void prompt(String input, GenerationOptions context,
      void Function(String?) callback) {
    if (context.apiType == ApiType.local) {
      LocalGeneration.prompt(input, context, callback);
    } else {
      RemoteGeneration.prompt(input, context, callback);
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
