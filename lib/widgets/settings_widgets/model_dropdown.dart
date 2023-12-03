import 'package:flutter/material.dart';
import 'package:maid/core/remote_generation.dart';
import 'package:maid/providers/model.dart';
import 'package:provider/provider.dart';

class ModelDropdown extends StatelessWidget {
  const ModelDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Model>(
      builder: (context, model, child) {
        return ListTile(
        title: Row(
          children: [
            const Expanded(
              child: Text("Remote Model"),
            ),
            FutureBuilder<List<String>>(
              future: RemoteGeneration.getOptions(model),
              builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
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
                      model.setParameter("remote_model", value);
                    }
                  },
                  initialSelection: model.parameters["remote_model"] ?? "",
                  width: 200,
                );
              },
            ),
          ],
        )
      );
    });
  }
}