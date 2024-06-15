import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/ui/mobile/widgets/tiles/text_field_list_tile.dart';
import 'package:provider/provider.dart';

class ApiKeyParameter extends StatelessWidget {
  const ApiKeyParameter({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final model = context.read<AppData>().currentSession.model;
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
