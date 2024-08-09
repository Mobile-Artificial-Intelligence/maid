import 'package:flutter/material.dart';
import 'package:maid/classes/providers/artificial_intelligence.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/ui/shared/tiles/slider_grid_tile.dart';
import 'package:provider/provider.dart';

class NKeepParameter extends StatelessWidget {
  const NKeepParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ArtificialIntelligence>(
      builder: nKeepBuilder,
    );
  }

  Widget nKeepBuilder(BuildContext context, ArtificialIntelligence ai, Widget? child) {
    return SliderGridTile(
      labelText: 'NKeep',
      inputValue: ai.llm.nKeep,
      sliderMin: 1.0,
      sliderMax: 1024.0,
      sliderDivisions: 1023,
      onValueChanged: (value) {
        LargeLanguageModel.of(context).nKeep = value.round();
      }
    );
  }
}
