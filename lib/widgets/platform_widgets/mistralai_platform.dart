import 'package:flutter/material.dart';
import 'package:maid/providers/model.dart';
import 'package:maid/widgets/parameter_widgets/api_token_parameter.dart';
import 'package:maid/widgets/settings_widgets/slider_list_tile.dart';
import 'package:maid/widgets/settings_widgets/text_field_list_tile.dart';
import 'package:maid/widgets/dropdowns/model_dropdown.dart';
import 'package:provider/provider.dart';

class MistralAiPlatform extends StatefulWidget {
  const MistralAiPlatform({super.key});

  @override
  State<StatefulWidget> createState() => _MistralAiPlatformState();
}

class _MistralAiPlatformState extends State<MistralAiPlatform> {
  late TextEditingController _remoteUrlController;

  @override
  void initState() {
    super.initState();

    final model = context.read<Model>();
    _remoteUrlController =
        TextEditingController(text: model.parameters["remote_url"]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Model>(builder: (context, model, child) {
      return Column(children: [
        ApiTokenParameter(),
        Divider(
          height: 20,
          indent: 10,
          endIndent: 10,
          color: Theme.of(context).colorScheme.primary,
        ),
        TextFieldListTile(
          headingText: 'Remote URL',
          labelText: 'Remote URL',
          controller: _remoteUrlController,
          onChanged: (value) {
            model.setParameter("remote_url", value);
          },
        ),
        const SizedBox(height: 8.0),
        const ModelDropdown(),
        const SizedBox(height: 20.0),
        Divider(
          height: 20,
          indent: 10,
          endIndent: 10,
          color: Theme.of(context).colorScheme.primary,
        ),
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
