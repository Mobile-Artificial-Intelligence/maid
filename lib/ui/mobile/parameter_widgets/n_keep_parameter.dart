import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:maid/ui/shared/tiles/slider_list_tile.dart';
import 'package:provider/provider.dart';

class NKeepParameter extends StatelessWidget {
  const NKeepParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        final session = appData.currentSession;
        
        return SliderListTile(
          labelText: 'NKeep',
          inputValue: session.model.nKeep,
          sliderMin: 1.0,
          sliderMax: 1024.0,
          sliderDivisions: 1023,
          onValueChanged: (value) {
            session.model.nKeep = value.round();
            session.notify();
          }
        );
      }
    );
  }
}
