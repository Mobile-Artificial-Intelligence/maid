import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maid/providers/model.dart';
import 'package:maid/widgets/dialogs.dart';
import 'package:maid/widgets/settings_widgets/double_button_row.dart';
import 'package:maid/widgets/dropdowns/format_dropdown.dart';
import 'package:maid/widgets/settings_widgets/slider_list_tile.dart';
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
        SwitchListTile(
          title: const Text('random_seed'),
          value: model.parameters["random_seed"] ?? true,
          onChanged: (value) {
            model.setParameter("random_seed", value);
          },
        ),
        Divider(
          height: 20,
          indent: 10,
          endIndent: 10,
          color: Theme.of(context).colorScheme.primary,
        ),
        if (!(model.parameters["random_seed"] ?? true))
          ListTile(
            title: Row(
              children: [
                const Expanded(
                  child: Text('seed'),
                ),
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'seed',
                    ),
                    onSubmitted: (value) {
                      model.setParameter("seed", int.parse(value));
                    },
                  ),
                ),
              ],
            ),
          ),
        SliderListTile(
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
            }),
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
