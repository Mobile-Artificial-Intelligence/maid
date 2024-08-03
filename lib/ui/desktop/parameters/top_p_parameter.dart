import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/ui/shared/tiles/slider_grid_tile.dart';
import 'package:provider/provider.dart';

class TopPParameter extends StatelessWidget {
  const TopPParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AppData, double>(
      selector: (context, appData) => appData.model.topP,
      builder: topPBuilder,
    );
  }

  Widget topPBuilder(BuildContext context, double topP, Widget? child) {
    return SliderGridTile(
      labelText: 'TopP',
      inputValue: topP,
      sliderMin: 0.0,
      sliderMax: 1.0,
      sliderDivisions: 100,
      onValueChanged: (value) {
        LargeLanguageModel.of(context).topP = value;
      }
    );
  }
}
