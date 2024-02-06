import 'package:flutter/material.dart';
import 'package:maid/providers/model.dart';
import 'package:maid/widgets/slider_list_tile.dart';
import 'package:provider/provider.dart';

class NKeepParameter extends StatelessWidget {
  const NKeepParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Model>(builder: (context, model, child) {
      return SliderListTile(
          labelText: 'n_keep',
          inputValue: model.parameters["n_keep"] ?? 48,
          sliderMin: 1.0,
          sliderMax: 1024.0,
          sliderDivisions: 1023,
          onValueChanged: (value) {
            model.setParameter("n_keep", value.round());
          });
    });
  }
}
