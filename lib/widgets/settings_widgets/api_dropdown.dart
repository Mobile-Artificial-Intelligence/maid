import 'package:flutter/material.dart';
import 'package:maid/providers/model.dart';
import 'package:provider/provider.dart';

class ApiDropdown extends StatelessWidget {
  const ApiDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Model>(
      builder: (context, model, child) {
        return ListTile(
        title: Row(
          children: [
            const Expanded(
              child: Text("API Type"),
            ),
            DropdownMenu<ApiType>(
              dropdownMenuEntries: const [
                DropdownMenuEntry<ApiType>(
                  value: ApiType.local,
                  label: "Local",
                ),
                DropdownMenuEntry<ApiType>(
                  value: ApiType.ollama,
                  label: "Ollama",
                ),
                DropdownMenuEntry<ApiType>(
                  value: ApiType.openAI,
                  label: "OpenAI",
                ),
              ],
              onSelected: (ApiType? value) {
                if (value != null) {
                  context.read<Model>().setParameter("api", value);
                }
              },
              initialSelection: context.watch<Model>().parameters["api"],
              width: 200,
            )
          ],
        )
      );
    });
  }
}