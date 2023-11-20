import 'package:flutter/material.dart';
import 'package:maid/core/remote_generation.dart';
import 'package:maid/types/model.dart';

class RemoteDropdown extends StatelessWidget {
  const RemoteDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          const Expanded(
            child: Text("Remote Model"),
          ),
          FutureBuilder<List<String>>(
            future: RemoteGeneration.getModels(),
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
                    model.parameters["remote_model"] = value;
                  }
                },
                width: 200,
              );
            },
          ),
        ],
      )
    );
  }

}