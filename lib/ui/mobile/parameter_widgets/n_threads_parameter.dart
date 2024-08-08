import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/enumerators/large_language_model_type.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:maid/ui/shared/tiles/slider_list_tile.dart';
import 'package:provider/provider.dart';

class NThreadsParameter extends StatelessWidget {
  const NThreadsParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: nThreadsBuilder,
    );
  }

  Widget nThreadsBuilder(BuildContext context, AppData appData, Widget? child) {
    final max = appData.model.type == LargeLanguageModelType.llamacpp
    ? Platform.numberOfProcessors.toDouble()
    : 128.0;

    return SliderListTile(
      labelText: 'NThreads',
      inputValue: appData.model.nThread,
      sliderMin: 1.0,
      sliderMax: max,
      sliderDivisions: max.round() - 1,
      onValueChanged: (value) {
        if (value.round() > Platform.numberOfProcessors) {
          LargeLanguageModel.of(context).nThread = Platform.numberOfProcessors;
        } 
        else {
          LargeLanguageModel.of(context).nThread = value.round();
        }
      }
    );
  }
}
