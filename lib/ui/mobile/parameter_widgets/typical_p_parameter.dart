import 'package:flutter/material.dart';
import 'package:maid/classes/providers/artificial_intelligence.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/ui/shared/tiles/slider_list_tile.dart';
import 'package:provider/provider.dart';

class TypicalPParameter extends StatelessWidget {
  const TypicalPParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ArtificialIntelligence>(
      builder: typicalPBuilder,
    );
  }

  Widget typicalPBuilder(BuildContext context, ArtificialIntelligence ai, Widget? child) {
    return SliderListTile(
      labelText: 'TypicalP',
      inputValue: ai.llm.typicalP,
      sliderMin: 0.0,
      sliderMax: 1.0,
      sliderDivisions: 100,
      onValueChanged: (value) {
        LargeLanguageModel.of(context).typicalP = value;
      }
    );
  }
}
