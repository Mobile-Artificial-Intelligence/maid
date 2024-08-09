import 'package:flutter/material.dart';
import 'package:maid/classes/providers/artificial_intelligence.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/ui/shared/tiles/slider_grid_tile.dart';
import 'package:provider/provider.dart';

class RepeatPenaltyParameter extends StatelessWidget {
  const RepeatPenaltyParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ArtificialIntelligence>(
      builder: repeatPenaltyBuilder,
    );
  }

  Widget repeatPenaltyBuilder(BuildContext context, ArtificialIntelligence ai, Widget? child) {
    return SliderGridTile(
      labelText: 'Repeat Penalty',
      inputValue: ai.llm.penaltyRepeat,
      sliderMin: 0.0,
      sliderMax: 2.0,
      sliderDivisions: 200,
      onValueChanged: (value) {
        LargeLanguageModel.of(context).penaltyRepeat = value;
      }
    );
  }
}
