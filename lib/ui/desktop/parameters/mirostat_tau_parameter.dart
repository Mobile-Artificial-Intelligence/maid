import 'package:flutter/material.dart';
import 'package:maid/classes/providers/artificial_intelligence.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/ui/shared/tiles/slider_grid_tile.dart';
import 'package:provider/provider.dart';

class MirostatTauParameter extends StatelessWidget {
  const MirostatTauParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ArtificialIntelligence>(
      builder: mirostatTauBuilder,
    );
  }

  Widget mirostatTauBuilder(BuildContext context, ArtificialIntelligence ai, Widget? child) {
    return SliderGridTile(
      labelText: 'MirostatTau',
      inputValue: ai.llm.mirostatTau,
      sliderMin: 0.0,
      sliderMax: 10.0,
      sliderDivisions: 100,
      onValueChanged: (value) {
        LargeLanguageModel.of(context).mirostatTau = value;
      }
    );
  }
}
