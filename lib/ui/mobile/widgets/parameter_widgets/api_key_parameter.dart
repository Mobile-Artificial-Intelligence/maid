import 'package:flutter/material.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/ui/mobile/widgets/tiles/text_field_list_tile.dart';

class ApiKeyParameter extends StatelessWidget {
  const ApiKeyParameter({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final model = Session.of(context).model;
    controller.text = model.token;

    return TextFieldListTile(
      headingText: "API Key",
      labelText: "API Key",
      controller: controller,
      onChanged: (value) {
        model.token = value;
      }
    );
  }
}
