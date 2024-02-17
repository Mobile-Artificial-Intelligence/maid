import 'package:flutter/material.dart';
import 'package:maid/providers/model.dart';
import 'package:maid/widgets/slider_list_tile.dart';
import 'package:provider/provider.dart';

class NBatchParameter extends StatelessWidget {
  const NBatchParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Model>(builder: (context, model, child) {
      return SliderListTile(
          labelText: 'n_batch',
          inputValue: model.parameters["n_batch"] ?? 8,
          sliderMin: 1.0,
          sliderMax: 512.0,
          sliderDivisions: 511,
          onValueChanged: (value) {
            model.setParameter("n_batch", value.round());
          });
    });
  }
}
