import 'package:flutter/material.dart';
import 'package:maid/providers/model.dart';
import 'package:maid/widgets/settings_widgets/text_field_list_tile.dart';
import 'package:provider/provider.dart';

class ApiTokenParameter extends StatelessWidget {
  final TextEditingController _apiTokenController = TextEditingController();

  ApiTokenParameter({super.key});

  @override
  Widget build(BuildContext context) {
    _apiTokenController.text =
        context.read<Model>().parameters["api_key"] ?? "";

    return TextFieldListTile(
        headingText: 'API Token',
        labelText: 'API Token',
        controller: _apiTokenController,
        onChanged: (value) {
          context.read<Model>().setParameter("api_key", value);
        });
  }
}
