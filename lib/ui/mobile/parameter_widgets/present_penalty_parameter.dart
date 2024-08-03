import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/ui/shared/tiles/slider_list_tile.dart';
import 'package:provider/provider.dart';

class PresentPenaltyParameter extends StatelessWidget {
  const PresentPenaltyParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AppData, double>(
      selector: (context, appData) => appData.model.penaltyPresent,
      builder: presentPenaltyBuilder,
    );
  }

  Widget presentPenaltyBuilder(BuildContext context, double penaltyPresent, Widget? child) {
    return SliderListTile(
      labelText: 'Presence Penalty',
      inputValue: penaltyPresent,
      sliderMin: 0.0,
      sliderMax: 1.0,
      sliderDivisions: 100,
      onValueChanged: (value) {
        LargeLanguageModel.of(context).penaltyPresent = value;
      }
    );
  }
}
