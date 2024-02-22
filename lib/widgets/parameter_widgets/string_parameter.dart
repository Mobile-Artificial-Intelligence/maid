import 'package:flutter/material.dart';
import 'package:maid/providers/model.dart';
import 'package:maid/widgets/text_field_list_tile.dart';
import 'package:provider/provider.dart';

class StringParameter extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  final String title;
  final String parameter;

  StringParameter({super.key, required this.title, required this.parameter});

  @override
  Widget build(BuildContext context) {
    _controller.text = context.read<AiPlatform>().parameters[parameter] ?? "";

    return TextFieldListTile(
        headingText: title,
        labelText: title,
        controller: _controller,
        onChanged: (value) {
          context.read<AiPlatform>().setParameter(parameter, value);
        });
  }
}
