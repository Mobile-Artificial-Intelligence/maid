import 'package:flutter/material.dart';
import 'package:maid/classes/providers/artificial_intelligence.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/ui/shared/tiles/slider_grid_tile.dart';
import 'package:provider/provider.dart';

class TopKParameter extends StatelessWidget {
  const TopKParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ArtificialIntelligence>(
      builder: topKBuilder,
    );
  }

  Widget topKBuilder(BuildContext context, ArtificialIntelligence ai, Widget? child) {
    return SliderGridTile(
      labelText: 'TopK',
      inputValue: ai.llm.topK,
      sliderMin: 1.0,
      sliderMax: 128.0,
      sliderDivisions: 127,
      onValueChanged: (value) {
        LargeLanguageModel.of(context).topK = value.round();
      }
    );
  }
}
