import 'package:flutter/material.dart';
import 'package:maid/classes/llama_cpp_model.dart';
import 'package:maid/ui/shared/widgets/tiles/text_field_container.dart';

class TemplateParameter extends StatelessWidget {
  const TemplateParameter({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text: LlamaCppModel.of(context).template
    );

    return TextFieldContainer(
      headingText: "Template",
      labelText: "Template",
      controller: controller,
      onChanged: (value) {
        LlamaCppModel.of(context).template = value;
      }
    );
  }
}
