import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:maid/ui/mobile/widgets/slider_list_tile.dart';
import 'package:provider/provider.dart';

class NThreadsParameter extends StatelessWidget {
  const NThreadsParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AiPlatform>(builder: (context, ai, child) {
      return SliderListTile(
          labelText: 'n_threads',
          inputValue: ai.nThread,
          sliderMin: 1.0,
          sliderMax: ai.apiType == AiPlatformType.llamacpp
              ? Platform.numberOfProcessors.toDouble()
              : 128.0,
          sliderDivisions: 127,
          onValueChanged: (value) {
            if (value.round() > Platform.numberOfProcessors) {
              ai.nThread = Platform.numberOfProcessors;
            } else {
              ai.nThread = value.round();
            }
          });
    });
  }
}
