import 'package:flutter/material.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/ui/shared/tiles/text_field_list_tile.dart';

class ApiKeyParameter extends StatelessWidget {
  const ApiKeyParameter({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text: LargeLanguageModel.of(context).token
    );

    return TextFieldListTile(
      headingText: "API Key",
      labelText: "API Key",
      controller: controller,
      onChanged: (value) {
        LargeLanguageModel.of(context).token = value;
      }
    );
  }
}
