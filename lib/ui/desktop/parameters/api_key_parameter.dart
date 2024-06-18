import 'package:flutter/material.dart';
import 'package:maid/classes/large_language_model.dart';
import 'package:maid/ui/shared/tiles/text_field_container.dart';

class ApiKeyParameter extends StatelessWidget {
  const ApiKeyParameter({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text: LargeLanguageModel.of(context).token
    );

    return TextFieldContainer(
      headingText: "API Key",
      labelText: "API Key",
      controller: controller,
      onChanged: (value) {
        LargeLanguageModel.of(context).token = value;
      }
    );
  }
}
