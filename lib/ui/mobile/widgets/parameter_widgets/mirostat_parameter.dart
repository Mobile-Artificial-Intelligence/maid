import 'package:flutter/material.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/ui/mobile/widgets/tiles/slider_list_tile.dart';
import 'package:provider/provider.dart';

class MirostatParameter extends StatelessWidget {
  const MirostatParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) {
        return SliderListTile(
          labelText: 'mirostat',
          inputValue: session.model.mirostat,
          sliderMin: 0.0,
          sliderMax: 128.0,
          sliderDivisions: 127,
          onValueChanged: (value) {
            session.model.mirostat = value.round();
          }
        );
      }
    );
  }
}
