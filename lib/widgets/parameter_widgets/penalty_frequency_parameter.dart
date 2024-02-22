import 'package:flutter/material.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:maid/widgets/slider_list_tile.dart';
import 'package:provider/provider.dart';

class PenaltyFrequencyParameter extends StatelessWidget {
  const PenaltyFrequencyParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AiPlatform>(builder: (context, ai, child) {
      return SliderListTile(
          labelText: 'penalty_freq',
          inputValue: ai.parameters["penalty_freq"] ?? 0.0,
          sliderMin: 0.0,
          sliderMax: 1.0,
          sliderDivisions: 100,
          onValueChanged: (value) {
            ai.setParameter("penalty_freq", value);
          });
    });
  }
}
