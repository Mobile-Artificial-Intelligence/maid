import 'package:flutter/material.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:maid/ui/mobile/widgets/tiles/slider_list_tile.dart';
import 'package:provider/provider.dart';

class NCtxParameter extends StatelessWidget {
  const NCtxParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AiPlatform>(builder: (context, ai, child) {
      return SliderListTile(
          labelText: 'n_ctx',
          inputValue: ai.nCtx,
          sliderMin: 1.0,
          sliderMax: 4096.0,
          sliderDivisions: 4095,
          onValueChanged: (value) {
            ai.nCtx = value.round();
          });
    });
  }
}
