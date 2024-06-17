import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/ui/shared/widgets/tiles/slider_grid_tile.dart';
import 'package:provider/provider.dart';

class MinPParameter extends StatelessWidget {
  const MinPParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        final session = appData.currentSession;
        
        return SliderGridTile(
          labelText: 'MinP',
          inputValue: session.model.minP,
          sliderMin: 0.0,
          sliderMax: 1.0,
          sliderDivisions: 100,
          onValueChanged: (value) {
            session.model.minP = value;
            session.notify();
          }
        );
      }
    );
  }
}
