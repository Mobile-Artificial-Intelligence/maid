import 'package:flutter/material.dart';
import 'package:maid/providers/model.dart';
import 'package:maid/widgets/parameter_widgets/seed_parameter.dart';
import 'package:maid/widgets/parameter_widgets/string_parameter.dart';
import 'package:maid/widgets/settings_widgets/slider_list_tile.dart';
import 'package:maid/widgets/dropdowns/model_dropdown.dart';
import 'package:provider/provider.dart';

class MistralAiPlatform extends StatefulWidget {
  const MistralAiPlatform({super.key});

  @override
  State<StatefulWidget> createState() => _MistralAiPlatformState();
}

class _MistralAiPlatformState extends State<MistralAiPlatform> {
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
            labelText: 'top_p',
            inputValue: model.parameters["top_p"] ?? 0.95,
            sliderMin: 0.0,
            sliderMax: 1.0,
            sliderDivisions: 100,
            onValueChanged: (value) {
              model.setParameter("top_p", value);
            }),
        SliderListTile(
            labelText: 'temperature',
            inputValue: model.parameters["temperature"] ?? 0.8,
            sliderMin: 0.0,
            sliderMax: 1.0,
            sliderDivisions: 100,
            onValueChanged: (value) {
              model.setParameter("temperature", value);
            }),
      ]);
    });
  }
}
