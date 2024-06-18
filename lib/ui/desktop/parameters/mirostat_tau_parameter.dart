import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/ui/shared/tiles/slider_grid_tile.dart';
import 'package:provider/provider.dart';

class MirostatTauParameter extends StatelessWidget {
  const MirostatTauParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        final session = appData.currentSession;

        return SliderGridTile(
          labelText: 'MirostatTau',
          inputValue: session.model.mirostatTau,
          sliderMin: 0.0,
          sliderMax: 10.0,
          sliderDivisions: 100,
          onValueChanged: (value) {
            session.model.mirostatTau = value;
            session.notify();
          }
        );
      }
    );
  }
}
