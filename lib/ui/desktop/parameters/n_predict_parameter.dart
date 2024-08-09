import 'package:flutter/material.dart';
import 'package:maid/classes/providers/artificial_intelligence.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/ui/shared/tiles/slider_grid_tile.dart';
import 'package:provider/provider.dart';

class NPredictParameter extends StatelessWidget {
  const NPredictParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ArtificialIntelligence>(
      builder: nPredictBuilder,
    );
  }

  Widget nPredictBuilder(BuildContext context, ArtificialIntelligence ai, Widget? child) {
    return SliderGridTile(
      labelText: 'Predict Length',
      inputValue: ai.llm.nPredict,
      sliderMin: 1.0,
      sliderMax: 4096.0,
      sliderDivisions: 4095,
      onValueChanged: (value) {
        LargeLanguageModel.of(context).nPredict = value.round();
      }
    );
  }
}
