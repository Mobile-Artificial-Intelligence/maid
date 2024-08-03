import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/ui/shared/tiles/slider_list_tile.dart';
import 'package:provider/provider.dart';

class TfsZParameter extends StatelessWidget {
  const TfsZParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AppData, double>(
      selector: (context, appData) => appData.model.tfsZ,
      builder: tfsZBuilder,
    );
  }

  Widget tfsZBuilder(BuildContext context, double tfsZ, Widget? child) {
    return SliderListTile(
      labelText: 'TfsZ',
      inputValue: tfsZ,
      sliderMin: 0.0,
      sliderMax: 1.0,
      sliderDivisions: 100,
      onValueChanged: (value) {
        LargeLanguageModel.of(context).tfsZ = value;
      }
    );
  }
}
