import 'package:flutter/material.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/static/remote_generation.dart';
import 'package:maid/static/local_generation.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:maid/classes/generation_options.dart';
import 'package:provider/provider.dart';

class GenerationManager {
  static void prompt(String input, BuildContext context) {
    context.read<Session>().busy = true;

    GenerationOptions options = GenerationOptions(
        ai: context.read<AiPlatform>(),
        character: context.read<Character>(),
        session: context.read<Session>());

    if (options.apiType == AiPlatformType.local) {
      LocalGeneration.prompt(input, options, context.read<Session>().stream);
    } else {
      RemoteGeneration.prompt(input, options, context.read<Session>().stream);
    }
  }

  static void stop() {
    LocalGeneration.stop();
  }

  static AiPlatformType checkApiRequirements(GenerationOptions context) {
    return context.apiType;
  }
}
