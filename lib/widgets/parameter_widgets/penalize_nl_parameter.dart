import 'package:flutter/material.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:provider/provider.dart';

class PenalizeNlParameter extends StatelessWidget {
  const PenalizeNlParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AiPlatform>(builder: (context, ai, child) {
      return SwitchListTile(
        title: const Text('penalize_nl'),
        value: ai.penalizeNewline,
        onChanged: (value) {
          ai.penalizeNewline = value;
        },
      );
    });
  }
}
