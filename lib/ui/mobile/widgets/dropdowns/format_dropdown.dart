import 'package:flutter/material.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:provider/provider.dart';
import 'package:maid_llm/maid_llm.dart';

class FormatDropdown extends StatelessWidget {
  const FormatDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AiPlatform>(builder: (context, ai, child) {
      return ListTile(
          title: Row(
        children: [
          const Expanded(
            child: Text("Prompt Format"),
          ),
          DropdownMenu<PromptFormat>(
            dropdownMenuEntries: const [
              DropdownMenuEntry<PromptFormat>(
                value: PromptFormat.raw,
                label: "Raw",
              ),
              DropdownMenuEntry<PromptFormat>(
                value: PromptFormat.chatml,
                label: "ChatML",
              ),
              DropdownMenuEntry<PromptFormat>(
                value: PromptFormat.alpaca,
                label: "Alpaca",
              )
            ],
            onSelected: (PromptFormat? value) {
              if (value != null) {
                ai.promptFormat = value;
              }
            },
            initialSelection: ai.promptFormat,
            width: 200,
          )
        ],
      ));
    });
  }
}
