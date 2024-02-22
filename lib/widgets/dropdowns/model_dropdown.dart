import 'package:flutter/material.dart';
import 'package:maid/providers/model.dart';
import 'package:provider/provider.dart';

class ModelDropdown extends StatelessWidget {
  const ModelDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AiPlatform>(builder: (context, model, child) {
      return ListTile(
          title: Row(
        children: [
          const Expanded(
            child: Text("Remote Model"),
          ),
          FutureBuilder<List<String>>(
            future: model.getOptions(),
            builder:
                (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
              if (snapshot.data == null) {
                return const SizedBox(height: 8.0);
              }

              List<DropdownMenuEntry<String>> dropdownEntries = snapshot.data!
                  .map((String modelName) => DropdownMenuEntry<String>(
                        value: modelName,
                        label: modelName,
                      ))
                  .toList();

              return DropdownMenu<String>(
                dropdownMenuEntries: dropdownEntries,
                onSelected: (String? value) {
                  if (value != null) {
                    model.model = value;
                  }
                },
                initialSelection: model.model,
                width: 200,
              );
            },
          ),
        ],
      ));
    });
  }
}
