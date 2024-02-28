import 'package:flutter/material.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:maid/ui/mobile/widgets/slider_list_tile.dart';
import 'package:provider/provider.dart';

class TypicalPParameter extends StatelessWidget {
  const TypicalPParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AiPlatform>(builder: (context, ai, child) {
      return SliderListTile(
          labelText: 'typical_p',
          inputValue: ai.typicalP,
          sliderMin: 0.0,
          sliderMax: 1.0,
          sliderDivisions: 100,
          onValueChanged: (value) {
            ai.typicalP = value;
          });
    });
  }
}
