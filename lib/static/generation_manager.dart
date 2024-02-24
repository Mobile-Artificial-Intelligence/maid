import 'package:flutter/material.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/static/remote_generation.dart';
import 'package:maid/static/local_generation.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:provider/provider.dart';

class GenerationManager {
  static void prompt(String input, BuildContext context) {
    context.read<Session>().busy = true;

    if (context.read<AiPlatform>().apiType == AiPlatformType.local) {
      LocalGeneration.prompt(input, context, context.read<Session>().stream);
    } else {
      RemoteGeneration.prompt(input, context, context.read<Session>().stream);
    }
  }

  static void stop() {
    LocalGeneration.stop();
  }
}
