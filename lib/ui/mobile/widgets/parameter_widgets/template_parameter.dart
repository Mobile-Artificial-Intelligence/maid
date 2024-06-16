import 'package:flutter/material.dart';
import 'package:maid/classes/llama_cpp_model.dart';
import 'package:maid/ui/mobile/widgets/tiles/text_field_list_tile.dart';

class TemplateParameter extends StatelessWidget {
  const TemplateParameter({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text: LlamaCppModel.of(context).template
    );

    return TextFieldListTile(
      headingText: "Template",
      labelText: "Template",
      controller: controller,
      onChanged: (value) {
        LlamaCppModel.of(context).template = value;
      }
    );
  }
}
