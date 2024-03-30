import 'package:flutter/material.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/ui/mobile/widgets/tiles/slider_list_tile.dart';
import 'package:provider/provider.dart';

class TopKParameter extends StatelessWidget {
  const TopKParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) {
        return SliderListTile(
          labelText: 'top_k',
          inputValue: session.model.topK,
          sliderMin: 1.0,
          sliderMax: 128.0,
          sliderDivisions: 127,
          onValueChanged: (value) {
            session.model.topK = value.round();
          }
        );
      }
    );
  }
}
