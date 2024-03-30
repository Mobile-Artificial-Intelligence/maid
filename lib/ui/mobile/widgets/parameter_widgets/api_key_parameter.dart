import 'package:flutter/material.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/ui/mobile/widgets/tiles/text_field_list_tile.dart';
import 'package:provider/provider.dart';

class ApiKeyParameter extends StatelessWidget {
  const ApiKeyParameter({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    controller.text = context.read<Session>().model.token;

    return TextFieldListTile(
        headingText: "API Key",
        labelText: "API Key",
        controller: controller,
        onChanged: (value) {
          context.read<Session>().apiKey = value;
        });
  }
}
