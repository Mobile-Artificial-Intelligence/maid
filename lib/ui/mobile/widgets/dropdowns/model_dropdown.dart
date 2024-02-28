import 'package:flutter/material.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:provider/provider.dart';

class ModelDropdown extends StatefulWidget {
  const ModelDropdown({super.key});

  @override
  State<ModelDropdown> createState() => _ModelDropdownState();
}

class _ModelDropdownState extends State<ModelDropdown> {
  Future<List<String>>? optionsFuture;

  @override
  void initState() {
    super.initState();
    optionsFuture = getOptions();
  }

  Future<List<String>> getOptions() {
    // Obtain your AiPlatform provider instance
    var ai = Provider.of<AiPlatform>(context, listen: false);
    return ai.getOptions();
  }

  void refreshOptions() {
    setState(() {
      optionsFuture = getOptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AiPlatform>(builder: (context, ai, child) {
      return ListTile(
          title: Row(
        children: [
          const Expanded(
            child: Text("Remote Model"),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshOptions,
          ),
          const SizedBox(width: 8.0),
          FutureBuilder<List<String>>(
            future: optionsFuture,
            builder:
                (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.data == null) {
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
                    ai.model = value;
                  }
                },
                initialSelection: ai.model,
                width: 200,
              );
            },
          ),
        ],
      ));
    });
  }
}
