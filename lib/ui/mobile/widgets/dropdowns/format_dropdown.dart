import 'package:flutter/material.dart';
import 'package:maid/classes/llama_cpp_model.dart';
import 'package:maid/providers/session.dart';
import 'package:provider/provider.dart';
import 'package:maid_llm/maid_llm.dart';

class FormatDropdown extends StatelessWidget {
  const FormatDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) {
        return ListTile(
            title: Row(
            children: [
              const Expanded(
                child: Text("Prompt Format"),
              ),
              DropdownMenu<PromptFormat>(
                hintText: "Select Format",
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Theme.of(context).colorScheme.secondary,
                  filled: true,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                ),
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
                    (session.model as LlamaCppModel).promptFormat = value;
                    session.notify();
                  }
                },
                initialSelection: (session.model as LlamaCppModel).promptFormat,
                width: 200,
              )
            ],
          )
        );
      }
    );
  }
}
