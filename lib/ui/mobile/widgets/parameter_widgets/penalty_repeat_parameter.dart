import 'package:flutter/material.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/ui/mobile/widgets/tiles/slider_list_tile.dart';
import 'package:provider/provider.dart';

class PenaltyRepeatParameter extends StatelessWidget {
  const PenaltyRepeatParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) {
        return SliderListTile(
          labelText: 'penalty_repeat',
          inputValue: session.model.penaltyRepeat,
          sliderMin: 0.0,
          sliderMax: 2.0,
          sliderDivisions: 200,
          onValueChanged: (value) {
            session.model.penaltyRepeat = value;
          }
        );
      }
    );
  }
}
