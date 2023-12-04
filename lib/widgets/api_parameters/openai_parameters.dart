import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maid/providers/model.dart';
import 'package:maid/widgets/settings_widgets/maid_slider.dart';
import 'package:maid/widgets/settings_widgets/maid_text_field.dart';
import 'package:maid/widgets/settings_widgets/model_dropdown.dart';
import 'package:provider/provider.dart';

class OpenAiParameters extends StatelessWidget {
  const OpenAiParameters({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Model>(
      builder: (context, model, child) {
        return Column(
          children: [
            MaidTextField(
              headingText: 'API Token', 
              labelText: 'API Token',
              initialValue: model.parameters["api_key"] ?? "",
              onSubmitted: (value) {
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
              initialValue: model.parameters["remote_url"] ?? "http://0.0.0.0:11434",
              onSubmitted: (value) {
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