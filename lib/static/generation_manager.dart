import 'package:flutter/material.dart';
import 'package:maid/core/remote_generation.dart';
import 'package:maid/core/local_generation.dart';

class GenerationManager {
  static bool busy = false;
  static bool remote = false;

  static void prompt(String input, BuildContext context) {
    if (remote) {
      RemoteGeneration.prompt(input, context);
    } else {
      LocalGeneration.instance.prompt(input, context);
    }
  }

  static void stop() {
    LocalGeneration.instance.stop();
  }

  static void cleanup() {
    LocalGeneration.instance.cleanup();
  }
}