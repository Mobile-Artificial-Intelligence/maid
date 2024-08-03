import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/ui/shared/tiles/slider_grid_tile.dart';
import 'package:provider/provider.dart';

class LastNPenaltyParameter extends StatelessWidget {
  const LastNPenaltyParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AppData, int>(
      selector: (context, appData) => appData.model.penaltyLastN,
      builder: lastNPenaltyBuilder,
    );
  }

  Widget lastNPenaltyBuilder(BuildContext context, int penaltyLastN, Widget? child) {
    return SliderGridTile(
      labelText: 'Last N Penalty',
      inputValue: penaltyLastN,
      sliderMin: 0.0,
      sliderMax: 128.0,
      sliderDivisions: 127,
      onValueChanged: (value) {
        LargeLanguageModel.of(context).penaltyLastN = value.round();
      }
    );
  }
}
