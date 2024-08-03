import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/ui/shared/tiles/slider_grid_tile.dart';
import 'package:provider/provider.dart';

class FrequencyPenaltyParameter extends StatelessWidget {
  const FrequencyPenaltyParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AppData, double>(
      selector: (context, appData) => appData.model.penaltyFreq,
      builder: frequencyPenaltyBuilder,
    );
  }

  Widget frequencyPenaltyBuilder(BuildContext context, double penaltyFreq, Widget? child) {
    return SliderGridTile(
      labelText: 'Frequency Penalty',
      inputValue: penaltyFreq,
      sliderMin: 0.0,
      sliderMax: 1.0,
      sliderDivisions: 100,
      onValueChanged: (value) {
        LargeLanguageModel.of(context).penaltyFreq = value;
      }
    );
  }
}
