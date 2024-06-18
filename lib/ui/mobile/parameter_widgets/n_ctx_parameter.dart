import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/ui/shared/tiles/slider_list_tile.dart';
import 'package:provider/provider.dart';

class NCtxParameter extends StatelessWidget {
  const NCtxParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        final session = appData.currentSession;
        
        return SliderListTile(
          labelText: 'NCtx',
          inputValue: session.model.nCtx,
          sliderMin: 0.0,
          sliderMax: 4096.0,
          sliderDivisions: 4095,
          onValueChanged: (value) {
            session.model.nCtx = value.round();
            session.notify();
          }
        );
      }
    );
  }
}
