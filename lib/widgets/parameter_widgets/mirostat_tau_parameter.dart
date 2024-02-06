import 'package:flutter/material.dart';
import 'package:maid/providers/model.dart';
import 'package:maid/widgets/slider_list_tile.dart';
import 'package:provider/provider.dart';

class MirostatTauParameter extends StatelessWidget {
  const MirostatTauParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Model>(builder: (context, model, child) {
      return SliderListTile(
          labelText: 'mirostat_tau',
          inputValue: model.parameters["mirostat_tau"] ?? 5.0,
          sliderMin: 0.0,
          sliderMax: 10.0,
          sliderDivisions: 100,
          onValueChanged: (value) {
            model.setParameter("mirostat_tau", value);
          });
    });
  }
}
