import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/ui/shared/tiles/slider_list_tile.dart';
import 'package:provider/provider.dart';

class NBatchParameter extends StatelessWidget {
  const NBatchParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AppData, int>(
      selector: (context, appData) => appData.model.nBatch,
      builder: nBatchBuilder,
    );
  }

  Widget nBatchBuilder(BuildContext context, int nBatch, Widget? child) {
    return SliderListTile(
      labelText: 'Batch Size',
      inputValue: nBatch,
      sliderMin: 1.0,
      sliderMax: 4096.0,
      sliderDivisions: 4095,
      onValueChanged: (value) {
        LargeLanguageModel.of(context).nBatch = value.round();
      }
    );
  }
}
