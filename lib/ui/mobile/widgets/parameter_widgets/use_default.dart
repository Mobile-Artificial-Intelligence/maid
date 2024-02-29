import 'package:flutter/material.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:provider/provider.dart';

class UseDefaultParameter extends StatelessWidget {
  const UseDefaultParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AiPlatform>(builder: (context, ai, child) {
      return SwitchListTile(
        title: const Text('Use Default Parameters'),
        value: ai.useDefault,
        onChanged: (value) {
          ai.useDefault = value;
        },
      );
    });
  }
}
