import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:maid/widgets/slider_list_tile.dart';
import 'package:provider/provider.dart';

class NThreadsParameter extends StatelessWidget {
  const NThreadsParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AiPlatform>(builder: (context, ai, child) {
      return SliderListTile(
          labelText: 'n_threads',
          inputValue: ai.parameters["n_threads"] ?? Platform.numberOfProcessors,
          sliderMin: 1.0,
          sliderMax: ai.apiType == ApiType.local
              ? Platform.numberOfProcessors.toDouble()
              : 128.0,
          sliderDivisions: 127,
          onValueChanged: (value) {
            ai.setParameter("n_threads", value.round());
            if (ai.parameters["n_threads"] > Platform.numberOfProcessors) {
              ai.setParameter("n_threads", Platform.numberOfProcessors);
            }
          });
    });
  }
}
