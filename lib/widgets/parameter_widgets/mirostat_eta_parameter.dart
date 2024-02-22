import 'package:flutter/material.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:maid/widgets/slider_list_tile.dart';
import 'package:provider/provider.dart';

class MirostatEtaParameter extends StatelessWidget {
  const MirostatEtaParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AiPlatform>(builder: (context, model, child) {
      return SliderListTile(
          labelText: 'mirostat_eta',
          inputValue: model.parameters["mirostat_eta"] ?? 0.1,
          sliderMin: 0.0,
          sliderMax: 1.0,
          sliderDivisions: 100,
          onValueChanged: (value) {
            model.setParameter("mirostat_eta", value);
          });
    });
  }
}
