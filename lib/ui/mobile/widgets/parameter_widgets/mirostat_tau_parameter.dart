import 'package:flutter/material.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/ui/mobile/widgets/tiles/slider_list_tile.dart';
import 'package:provider/provider.dart';

class MirostatTauParameter extends StatelessWidget {
  const MirostatTauParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) {
        return SliderListTile(
          labelText: 'mirostat_tau',
          inputValue: session.model.mirostatTau,
          sliderMin: 0.0,
          sliderMax: 10.0,
          sliderDivisions: 100,
          onValueChanged: (value) {
            session.model.mirostatTau = value;
          }
        );
      }
    );
  }
}
