import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/ui/mobile/widgets/tiles/slider_list_tile.dart';
import 'package:provider/provider.dart';

class TemperatureParameter extends StatelessWidget {
  const TemperatureParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        final session = appData.currentSession;

        return SliderListTile(
          labelText: 'Temperature',
          inputValue: session.model.temperature,
          sliderMin: 0.0,
          sliderMax: 1.0,
          sliderDivisions: 100,
          onValueChanged: (value) {
            session.model.temperature = value;
            session.notify();
          }
        );
      }
    );
  }
}
