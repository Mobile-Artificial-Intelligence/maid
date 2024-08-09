import 'package:flutter/material.dart';
import 'package:maid/classes/providers/artificial_intelligence.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/ui/shared/tiles/slider_grid_tile.dart';
import 'package:provider/provider.dart';

class FrequencyPenaltyParameter extends StatelessWidget {
  const FrequencyPenaltyParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ArtificialIntelligence>(
      builder: frequencyPenaltyBuilder,
    );
  }

  Widget frequencyPenaltyBuilder(BuildContext context, ArtificialIntelligence ai, Widget? child) {
    return SliderGridTile(
      labelText: 'Frequency Penalty',
      inputValue: ai.llm.penaltyFreq,
      sliderMin: 0.0,
      sliderMax: 1.0,
      sliderDivisions: 100,
      onValueChanged: (value) {
        LargeLanguageModel.of(context).penaltyFreq = value;
      }
    );
  }
}
