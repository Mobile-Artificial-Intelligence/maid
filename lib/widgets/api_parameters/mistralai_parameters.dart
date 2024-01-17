import 'package:flutter/material.dart';
import 'package:maid/providers/model.dart';
import 'package:maid/widgets/settings_widgets/maid_slider.dart';
import 'package:maid/widgets/settings_widgets/maid_text_field.dart';
import 'package:maid/widgets/dropdowns/model_dropdown.dart';
import 'package:provider/provider.dart';

class MistralAiParameters extends StatefulWidget {
  const MistralAiParameters({super.key});
  
  @override
  State<StatefulWidget> createState() => _MistralAiParametersState();
}

class _MistralAiParametersState extends State<MistralAiParameters> {
  late TextEditingController _apiTokenController;
  late TextEditingController _remoteUrlController;

  @override
  void initState() {
    super.initState();

    final model = context.read<Model>();
    _apiTokenController = TextEditingController(text: model.parameters["api_key"]);
    _remoteUrlController = TextEditingController(text: model.parameters["remote_url"]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Model>(
      builder: (context, model, child) {
        return Column(
          children: [
            MaidTextField(
              headingText: 'API Token', 
              labelText: 'API Token',
              controller: _apiTokenController,
              onChanged: (value) {
                model.setParameter("api_key", value);
              } ,
            ),
            Divider(
              height: 20,
              indent: 10,
              endIndent: 10,
              color: Theme.of(context).colorScheme.primary,
            ),
            MaidTextField(
              headingText: 'Remote URL', 
              labelText: 'Remote URL',
              controller: _remoteUrlController,
              onChanged: (value) {
                model.setParameter("remote_url", value);
              } ,
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
            MaidSlider(
              labelText: 'top_p',
              inputValue: model.parameters["top_p"] ?? 0.95,
              sliderMin: 0.0,
              sliderMax: 1.0,
              sliderDivisions: 100,
              onValueChanged: (value) {
                model.setParameter("top_p", value);
              }
            ),
            MaidSlider(
              labelText: 'temperature',
              inputValue: model.parameters["temperature"] ?? 0.8,
              sliderMin: 0.0,
              sliderMax: 1.0,
              sliderDivisions: 100,
              onValueChanged: (value) {
                model.setParameter("temperature", value);
              }
            ),
          ]
        );
    });
  }
}