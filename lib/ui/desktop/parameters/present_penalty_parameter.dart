import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/ui/shared/tiles/slider_grid_tile.dart';
import 'package:provider/provider.dart';

class PresentPenaltyParameter extends StatelessWidget {
  const PresentPenaltyParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        final session = appData.currentSession;
        
        return SliderGridTile(
          labelText: 'Presence Penalty',
          inputValue: session.model.penaltyPresent,
          sliderMin: 0.0,
          sliderMax: 1.0,
          sliderDivisions: 100,
          onValueChanged: (value) {
            session.model.penaltyPresent = value;
            session.notify();
          }
        );
      }
    );
  }
}
