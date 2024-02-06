import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maid/providers/model.dart';
import 'package:maid/widgets/slider_list_tile.dart';
import 'package:provider/provider.dart';

class NThreadsParameter extends StatelessWidget {
  const NThreadsParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Model>(builder: (context, model, child) {
      return SliderListTile(
          labelText: 'n_threads',
          inputValue:
              model.parameters["n_threads"] ?? Platform.numberOfProcessors,
          sliderMin: 1.0,
          sliderMax: model.apiType == ApiType.local
              ? Platform.numberOfProcessors.toDouble()
              : 128.0,
          sliderDivisions: 127,
          onValueChanged: (value) {
            model.setParameter("n_threads", value.round());
            if (model.parameters["n_threads"] > Platform.numberOfProcessors) {
              model.setParameter("n_threads", Platform.numberOfProcessors);
            }
          });
    });
  }
}
