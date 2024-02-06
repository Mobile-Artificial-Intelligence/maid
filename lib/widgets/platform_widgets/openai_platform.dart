import 'package:flutter/material.dart';
import 'package:maid/providers/model.dart';
import 'package:maid/widgets/parameter_widgets/n_predict_parameter.dart';
import 'package:maid/widgets/parameter_widgets/seed_parameter.dart';
import 'package:maid/widgets/parameter_widgets/string_parameter.dart';
import 'package:maid/widgets/parameter_widgets/top_p_parameter.dart';
import 'package:maid/widgets/slider_list_tile.dart';
import 'package:maid/widgets/dropdowns/model_dropdown.dart';
import 'package:provider/provider.dart';

class OpenAiPlatform extends StatefulWidget {
  const OpenAiPlatform({super.key});

  @override
  State<StatefulWidget> createState() => _OpenAiPlatformState();
}

class _OpenAiPlatformState extends State<OpenAiPlatform> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Model>(builder: (context, model, child) {
      return Column(children: [
        StringParameter(title: "API Token", parameter: "api_key"),
        Divider(
          height: 20,
          indent: 10,
          endIndent: 10,
          color: Theme.of(context).colorScheme.primary,
        ),
        StringParameter(title: "Remote URL", parameter: "remote_url"),
        const SizedBox(height: 8.0),
        const ModelDropdown(),
        const SizedBox(height: 20.0),
        const SeedParameter(),
        SliderListTile(
            labelText: 'temperature',
            inputValue: model.parameters["temperature"] ?? 0.8,
            sliderMin: 0.0,
            sliderMax: 1.0,
            sliderDivisions: 100,
            onValueChanged: (value) {
              model.setParameter("temperature", value);
            }),
        SliderListTile(
            labelText: 'penalty_freq',
            inputValue: model.parameters["penalty_freq"] ?? 0.0,
            sliderMin: 0.0,
            sliderMax: 1.0,
            sliderDivisions: 100,
            onValueChanged: (value) {
              model.setParameter("penalty_freq", value);
            }),
        SliderListTile(
            labelText: 'penalty_present',
            inputValue: model.parameters["penalty_present"] ?? 0.0,
            sliderMin: 0.0,
            sliderMax: 1.0,
            sliderDivisions: 100,
            onValueChanged: (value) {
              model.setParameter("penalty_present", value);
            }),
        const NPredictParameter(),
        const TopPParameter()
      ]);
    });
  }
}
