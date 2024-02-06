import 'package:flutter/material.dart';
import 'package:maid/providers/model.dart';
import 'package:maid/widgets/slider_list_tile.dart';
import 'package:provider/provider.dart';

class PenaltyLastNParameter extends StatelessWidget {
  const PenaltyLastNParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Model>(builder: (context, model, child) {
      return SliderListTile(
          labelText: 'penalty_last_n',
          inputValue: model.parameters["penalty_last_n"] ?? 64,
          sliderMin: 0.0,
          sliderMax: 128.0,
          sliderDivisions: 127,
          onValueChanged: (value) {
            model.setParameter("penalty_last_n", value.round());
          });
    });
  }
}
