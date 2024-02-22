import 'package:flutter/material.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:maid/widgets/slider_list_tile.dart';
import 'package:provider/provider.dart';

class MirostatParameter extends StatelessWidget {
  const MirostatParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AiPlatform>(builder: (context, ai, child) {
      return SliderListTile(
          labelText: 'mirostat',
          inputValue: ai.parameters["mirostat"] ?? 0.0,
          sliderMin: 0.0,
          sliderMax: 128.0,
          sliderDivisions: 127,
          onValueChanged: (value) {
            ai.setParameter("mirostat", value.round());
          });
    });
  }
}
