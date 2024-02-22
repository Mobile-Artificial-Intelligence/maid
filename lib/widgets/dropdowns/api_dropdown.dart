import 'package:flutter/material.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:provider/provider.dart';

class ApiDropdown extends StatelessWidget {
  const ApiDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AiPlatform>(builder: (context, ai, child) {
      return ListTile(
          title: Row(
        children: [
          const Expanded(
            child: Text("API Type"),
          ),
          DropdownMenu<AiPlatformType>(
            dropdownMenuEntries: const [
              DropdownMenuEntry<AiPlatformType>(
                value: AiPlatformType.local,
                label: "Local",
              ),
              DropdownMenuEntry<AiPlatformType>(
                value: AiPlatformType.ollama,
                label: "Ollama",
              ),
              DropdownMenuEntry<AiPlatformType>(
                value: AiPlatformType.openAI,
                label: "OpenAI",
              ),
              DropdownMenuEntry<AiPlatformType>(
                value: AiPlatformType.mistralAI,
                label: "MistralAI",
              ),
            ],
            onSelected: (AiPlatformType? value) {
              if (value != null) {
                ai.apiType = value;
              }
            },
            initialSelection: ai.apiType,
            width: 200,
          )
        ],
      ));
    });
  }
}
