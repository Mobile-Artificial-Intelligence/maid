import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maid/enumerators/large_language_model_type.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:maid/ui/shared/tiles/slider_grid_tile.dart';
import 'package:provider/provider.dart';

class NThreadsParameter extends StatelessWidget {
  const NThreadsParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        final session = appData.currentSession;
      
        return SliderGridTile(
          labelText: 'NThreads',
          inputValue: session.model.nThread,
          sliderMin: 1.0,
          sliderMax: session.model.type == LargeLanguageModelType.llamacpp
              ? Platform.numberOfProcessors.toDouble()
              : 128.0,
          sliderDivisions: 127,
          onValueChanged: (value) {
            if (value.round() > Platform.numberOfProcessors) {
              session.model.nThread = Platform.numberOfProcessors;
            } else {
              session.model.nThread = value.round();
            }

            session.notify();
          }
        );
      }
    );
  }
}
