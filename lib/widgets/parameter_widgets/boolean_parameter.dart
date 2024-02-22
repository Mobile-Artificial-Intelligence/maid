import 'package:flutter/material.dart';
import 'package:maid/providers/model.dart';
import 'package:provider/provider.dart';

class BooleanParameter extends StatelessWidget {
  final String title;
  final String parameter;

  const BooleanParameter(
      {super.key, required this.title, required this.parameter});

  @override
  Widget build(BuildContext context) {
    return Consumer<AiPlatform>(builder: (context, model, child) {
      return SwitchListTile(
        title: Text(title),
        value: model.parameters[parameter] ?? false,
        onChanged: (value) {
          model.setParameter(parameter, value);
        },
      );
    });
  }
}
