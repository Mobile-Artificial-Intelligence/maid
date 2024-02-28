import 'package:flutter/material.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:maid/ui/mobile/widgets/slider_list_tile.dart';
import 'package:provider/provider.dart';

class PenaltyLastNParameter extends StatelessWidget {
  const PenaltyLastNParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AiPlatform>(builder: (context, ai, child) {
      return SliderListTile(
          labelText: 'penalty_last_n',
          inputValue: ai.penaltyLastN,
          sliderMin: 0.0,
          sliderMax: 128.0,
          sliderDivisions: 127,
          onValueChanged: (value) {
            ai.penaltyLastN = value.round();
          });
    });
  }
}
