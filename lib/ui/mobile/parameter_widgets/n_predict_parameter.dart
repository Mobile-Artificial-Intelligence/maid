import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/ui/shared/tiles/slider_list_tile.dart';
import 'package:provider/provider.dart';

class NPredictParameter extends StatelessWidget {
  const NPredictParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AppData, int>(
      selector: (context, appData) => appData.model.nPredict,
      builder: nPredictBuilder,
    );
  }

  Widget nPredictBuilder(BuildContext context, int nPredict, Widget? child) {
    return SliderListTile(
      labelText: 'Predict Length',
      inputValue: nPredict,
      sliderMin: 1.0,
      sliderMax: 4096.0,
      sliderDivisions: 4095,
      onValueChanged: (value) {
        LargeLanguageModel.of(context).nPredict = value.round();
      }
    );
  }
}
