import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maid/providers/model.dart';
import 'package:maid/widgets/parameter_widgets/boolean_parameter.dart';
import 'package:maid/widgets/parameter_widgets/seed_parameter.dart';
import 'package:maid/widgets/parameter_widgets/string_parameter.dart';
import 'package:maid/widgets/slider_list_tile.dart';
import 'package:maid/widgets/dropdowns/model_dropdown.dart';

class OllamaPlatform extends StatefulWidget {
  const OllamaPlatform({super.key});

  @override
  State<StatefulWidget> createState() => _OllamaPlatformState();
}

class _OllamaPlatformState extends State<OllamaPlatform> {
  @override
  Widget build(BuildContext context) {
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
      Divider(
        height: 20,
        indent: 10,
        endIndent: 10,
        color: Theme.of(context).colorScheme.primary,
      ),
      const BooleanParameter(
          title: "Penalize Newline", parameter: "penalize_nl"),
      const SeedParameter(),
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
          inputValue: model.parameters["n_batch"] ?? 8,
          sliderMin: 1.0,
          sliderMax: 4096.0,
          sliderDivisions: 4095,
          onValueChanged: (value) {
            model.setParameter("n_batch", value.round());
          }),
      SliderListTile(
          labelText: 'n_predict',
          inputValue: model.parameters["n_predict"] ?? 512,
          sliderMin: 1.0,
          sliderMax: 1024.0,
          sliderDivisions: 1023,
          onValueChanged: (value) {
            model.setParameter("n_predict", value.round());
          }),
      SliderListTile(
          labelText: 'n_keep',
          inputValue: model.parameters["n_keep"] ?? 48,
          sliderMin: 1.0,
          sliderMax: 1024.0,
          sliderDivisions: 1023,
          onValueChanged: (value) {
            model.setParameter("n_keep", value.round());
          }),
      SliderListTile(
          labelText: 'top_k',
          inputValue: model.parameters["top_k"] ?? 40,
          sliderMin: 1.0,
          sliderMax: 128.0,
          sliderDivisions: 127,
          onValueChanged: (value) {
            model.setParameter("top_k", value.round());
          }),
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
          labelText: 'tfs_z',
          inputValue: model.parameters["tfs_z"] ?? 1.0,
          sliderMin: 0.0,
          sliderMax: 1.0,
          sliderDivisions: 100,
          onValueChanged: (value) {
            model.setParameter("tfs_z", value);
          }),
      SliderListTile(
          labelText: 'typical_p',
          inputValue: model.parameters["typical_p"] ?? 1.0,
          sliderMin: 0.0,
          sliderMax: 1.0,
          sliderDivisions: 100,
          onValueChanged: (value) {
            model.setParameter("typical_p", value);
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
      SliderListTile(
          labelText: 'penalty_last_n',
          inputValue: model.parameters["penalty_last_n"] ?? 64,
          sliderMin: 0.0,
          sliderMax: 128.0,
          sliderDivisions: 127,
          onValueChanged: (value) {
            model.setParameter("penalty_last_n", value.round());
          }),
      SliderListTile(
          labelText: 'penalty_repeat',
          inputValue: model.parameters["penalty_repeat"] ?? 1.1,
          sliderMin: 0.0,
          sliderMax: 2.0,
          sliderDivisions: 200,
          onValueChanged: (value) {
            model.setParameter("penalty_repeat", value);
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
      SliderListTile(
          labelText: 'mirostat',
          inputValue: model.parameters["mirostat"] ?? 0.0,
          sliderMin: 0.0,
          sliderMax: 128.0,
          sliderDivisions: 127,
          onValueChanged: (value) {
            model.setParameter("mirostat", value.round());
          }),
      SliderListTile(
          labelText: 'mirostat_tau',
          inputValue: model.parameters["mirostat_tau"] ?? 5.0,
          sliderMin: 0.0,
          sliderMax: 10.0,
          sliderDivisions: 100,
          onValueChanged: (value) {
            model.setParameter("mirostat_tau", value);
          }),
      SliderListTile(
          labelText: 'mirostat_eta',
          inputValue: model.parameters["mirostat_eta"] ?? 0.1,
          sliderMin: 0.0,
          sliderMax: 1.0,
          sliderDivisions: 100,
          onValueChanged: (value) {
            model.setParameter("mirostat_eta", value);
          }),
    ]);
  }
}
