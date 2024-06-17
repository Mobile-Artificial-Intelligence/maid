import 'package:flutter/material.dart';
import 'package:maid/classes/llama_cpp_model.dart';
import 'package:maid/providers/app_preferences.dart';
import 'package:maid/ui/shared/widgets/tiles/text_field_grid_tile.dart';
import 'package:maid/ui/shared/widgets/tiles/text_field_list_tile.dart';

class TemplateParameter extends StatelessWidget {
  const TemplateParameter({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text: LlamaCppModel.of(context).template
    );

    if (AppPreferences.of(context).isDesktop) {
      return TextFieldGridTile(
        headingText: "Template",
        labelText: "Template",
        controller: controller,
        onChanged: (value) {
          LlamaCppModel.of(context).template = value;
        }
      );
    }

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
