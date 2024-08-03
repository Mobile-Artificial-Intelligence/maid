import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/ui/shared/tiles/slider_list_tile.dart';
import 'package:provider/provider.dart';

class MirostatTauParameter extends StatelessWidget {
  const MirostatTauParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AppData, double>(
      selector: (context, appData) => appData.model.mirostatTau,
      builder: mirostatTauBuilder,
    );
  }

  Widget mirostatTauBuilder(BuildContext context, double mirostatTau, Widget? child) {
    return SliderListTile(
      labelText: 'MirostatTau',
      inputValue: mirostatTau,
      sliderMin: 0.0,
      sliderMax: 10.0,
      sliderDivisions: 100,
      onValueChanged: (value) {
        LargeLanguageModel.of(context).mirostatTau = value;
      }
    );
  }
}
