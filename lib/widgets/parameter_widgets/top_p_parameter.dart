import 'package:flutter/material.dart';
import 'package:maid/providers/model.dart';
import 'package:maid/widgets/slider_list_tile.dart';
import 'package:provider/provider.dart';

class TopPParameter extends StatelessWidget {
  const TopPParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Model>(builder: (context, model, child) {
      return SliderListTile(
          labelText: 'top_p',
          inputValue: model.parameters["top_p"] ?? 0.95,
          sliderMin: 0.0,
          sliderMax: 1.0,
          sliderDivisions: 100,
          onValueChanged: (value) {
            model.setParameter("top_p", value);
          });
    });
  }
}
