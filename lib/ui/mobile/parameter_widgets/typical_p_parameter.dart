import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/ui/shared/tiles/slider_list_tile.dart';
import 'package:provider/provider.dart';

class TypicalPParameter extends StatelessWidget {
  const TypicalPParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        final session = appData.currentSession;
        return SliderListTile(
          labelText: 'TypicalP',
          inputValue: session.model.typicalP,
          sliderMin: 0.0,
          sliderMax: 1.0,
          sliderDivisions: 100,
          onValueChanged: (value) {
            session.model.typicalP = value;
            session.notify();
          }
        );
      }
    );
  }
}
