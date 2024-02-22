import 'package:flutter/material.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:maid/widgets/slider_list_tile.dart';
import 'package:provider/provider.dart';

class PenaltyRepeatParameter extends StatelessWidget {
  const PenaltyRepeatParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AiPlatform>(builder: (context, ai, child) {
      return SliderListTile(
          labelText: 'penalty_repeat',
          inputValue: ai.parameters["penalty_repeat"] ?? 1.1,
          sliderMin: 0.0,
          sliderMax: 2.0,
          sliderDivisions: 200,
          onValueChanged: (value) {
            ai.setParameter("penalty_repeat", value);
          });
    });
  }
}
