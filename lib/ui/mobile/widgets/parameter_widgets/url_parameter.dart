import 'package:flutter/material.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:maid/ui/mobile/widgets/text_field_list_tile.dart';
import 'package:provider/provider.dart';

class UrlParameter extends StatelessWidget {
  const UrlParameter({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    controller.text = context.read<AiPlatform>().url;

    return TextFieldListTile(
        headingText: "URL",
        labelText: "URL",
        controller: controller,
        onChanged: (value) {
          context.read<AiPlatform>().url = value;
        });
  }
}
