import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maid/providers/model.dart';
import 'package:maid/widgets/dialogs.dart';
import 'package:maid/widgets/parameter_widgets/n_threads_parameter.dart';
import 'package:maid/widgets/parameter_widgets/seed_parameter.dart';
import 'package:maid/widgets/double_button_row.dart';
import 'package:maid/widgets/dropdowns/format_dropdown.dart';
import 'package:maid/widgets/slider_list_tile.dart';
import 'package:provider/provider.dart';

class LocalPlatform extends StatelessWidget {
  const LocalPlatform({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Model>(builder: (context, model, child) {
      return Column(children: [
        Divider(
          height: 20,
          indent: 10,
          endIndent: 10,
          color: Theme.of(context).colorScheme.primary,
        ),
        ListTile(
          title: Row(
            children: [
              const Expanded(
                child: Text("Model Path"),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  model.parameters["path"] ?? "None",
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15.0),
        DoubleButtonRow(
            leftText: "Load GGUF",
            leftOnPressed: () {
              storageOperationDialog(context, model.loadModelFile);
            },
            rightText: "Unload GGUF",
            rightOnPressed: () {
              model.setParameter("path", "");
            }),
        Divider(
          height: 20,
          indent: 10,
          endIndent: 10,
          color: Theme.of(context).colorScheme.primary,
        ),
        const FormatDropdown(),
        const SeedParameter(),
        const NThreadsParameter(),
        SliderListTile(
            labelText: 'n_ctx',
            inputValue: model.parameters["n_ctx"] ?? 512,
            sliderMin: 1.0,
            sliderMax: 4096.0,
            sliderDivisions: 4095,
            onValueChanged: (value) {
              model.setParameter("n_ctx", value.round());
            }),
        SliderListTile(
            labelText: 'n_batch',
            inputValue: model.parameters["n_batch"] ?? 512,
            sliderMin: 1.0,
            sliderMax: 4096.0,
            sliderDivisions: 4095,
            onValueChanged: (value) {
              model.setParameter("n_batch", value.round());
            }),
      ]);
    });
  }
}
