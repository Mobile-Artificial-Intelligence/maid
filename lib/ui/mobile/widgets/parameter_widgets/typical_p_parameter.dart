import 'package:flutter/material.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/ui/mobile/widgets/tiles/slider_list_tile.dart';
import 'package:provider/provider.dart';

class TypicalPParameter extends StatelessWidget {
  const TypicalPParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) {
        return SliderListTile(
          labelText: 'typical_p',
          inputValue: session.model.typicalP,
          sliderMin: 0.0,
          sliderMax: 1.0,
          sliderDivisions: 100,
          onValueChanged: (value) {
            session.model.typicalP = value;
          }
        );
      }
    );
  }
}
