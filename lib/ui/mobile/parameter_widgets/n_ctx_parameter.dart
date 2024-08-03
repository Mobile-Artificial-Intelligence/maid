import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/ui/shared/tiles/slider_list_tile.dart';
import 'package:provider/provider.dart';

class NCtxParameter extends StatelessWidget {
  const NCtxParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AppData, int>(
      selector: (context, appData) => appData.model.nCtx,
      builder: nCtxBuilder,
    );
  }

  Widget nCtxBuilder(BuildContext context, int nCtx, Widget? child) {
    return SliderListTile(
      labelText: 'Context Length',
      inputValue: nCtx,
      sliderMin: 0.0,
      sliderMax: 4096.0,
      sliderDivisions: 4095,
      onValueChanged: (value) {
        LargeLanguageModel.of(context).nCtx = value.round();
      }
    );
  }
}
