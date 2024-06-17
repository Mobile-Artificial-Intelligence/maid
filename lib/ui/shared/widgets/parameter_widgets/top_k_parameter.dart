import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/ui/shared/widgets/tiles/slider_list_tile.dart';
import 'package:provider/provider.dart';

class TopKParameter extends StatelessWidget {
  const TopKParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        final session = appData.currentSession;
        
        return SliderListTile(
          labelText: 'TopK',
          inputValue: session.model.topK,
          sliderMin: 1.0,
          sliderMax: 128.0,
          sliderDivisions: 127,
          onValueChanged: (value) {
            session.model.topK = value.round();
            session.notify();
          }
        );
      }
    );
  }
}
