import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/ui/shared/tiles/slider_grid_tile.dart';
import 'package:provider/provider.dart';

class NBatchParameter extends StatelessWidget {
  const NBatchParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        final session = appData.currentSession;
        
        return SliderGridTile(
          labelText: 'NBatch',
          inputValue: session.model.nBatch,
          sliderMin: 1.0,
          sliderMax: 4096.0,
          sliderDivisions: 4095,
          onValueChanged: (value) {
            session.model.nBatch = value.round();
            session.notify();
          }
        );
      }
    );
  }
}
