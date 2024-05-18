import 'package:flutter/material.dart';
import 'package:maid/classes/llama_cpp_model.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/ui/mobile/widgets/tiles/text_field_list_tile.dart';
import 'package:provider/provider.dart';

class TemplateParameter extends StatelessWidget {
  const TemplateParameter({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    controller.text = (context.read<Session>().model as LlamaCppModel).template;

    return TextFieldListTile(
      headingText: "Template",
      labelText: "Template",
      controller: controller,
      onChanged: (value) {
        (context.read<Session>().model as LlamaCppModel).template = value;
      }
    );
  }
}
