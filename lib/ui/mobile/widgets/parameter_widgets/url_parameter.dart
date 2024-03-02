import 'package:flutter/material.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:provider/provider.dart';

class UrlParameter extends StatelessWidget {
  const UrlParameter({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    controller.text = context.read<AiPlatform>().url;


    return ListTile(
      title: Row(
        children: [
          const Expanded(
            child: Text("URL"),
          ),
          IconButton(
            onPressed: () async {
              controller.text = await context.read<AiPlatform>().resetUrl();
            }, 
            icon: const Icon(Icons.refresh),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              keyboardType: TextInputType.text,
              maxLines: 1,
              cursorColor: Theme.of(context).colorScheme.secondary,
              controller: controller,
              decoration: const InputDecoration(
                labelText: "URL",
              ),
              onChanged: (value) {
                context.read<AiPlatform>().url = value;
              },
            ),
          ),
        ],
      ),
    );
  }
}
