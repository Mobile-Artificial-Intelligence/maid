import 'package:flutter/material.dart';
import 'package:maid/classes/providers/artificial_intelligence.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/ui/shared/tiles/slider_list_tile.dart';
import 'package:provider/provider.dart';

class LastNPenaltyParameter extends StatelessWidget {
  const LastNPenaltyParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ArtificialIntelligence>(
      builder: lastNPenaltyBuilder,
    );
  }

  Widget lastNPenaltyBuilder(BuildContext context, ArtificialIntelligence ai, Widget? child) {
    return SliderListTile(
      labelText: 'Last N Penalty',
      inputValue: ai.llm.penaltyLastN,
      sliderMin: 0.0,
      sliderMax: 128.0,
      sliderDivisions: 127,
      onValueChanged: (value) {
        LargeLanguageModel.of(context).penaltyLastN = value.round();
      }
    );
  }
}
