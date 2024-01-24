import 'package:flutter/material.dart';
import 'package:maid/providers/model.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'package:provider/provider.dart';

class FormatDropdown extends StatelessWidget {
  const FormatDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Model>(
      builder: (context, model, child) {
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
                  model.setPromptFormat(value);
                }
              },
              initialSelection: model.format,
              width: 200,
            )
          ],
        )
      );
    });
  }
}