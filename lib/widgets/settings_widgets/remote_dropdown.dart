import 'package:flutter/material.dart';
import 'package:maid/core/remote_generation.dart';
import 'package:maid/static/host.dart';
import 'package:maid/types/model.dart';
import 'package:provider/provider.dart';

class RemoteDropdown extends StatefulWidget {
  final String url;

  const RemoteDropdown({super.key, required this.url});

  @override
  State<RemoteDropdown> createState() => _RemoteDropdownState();
}

class _RemoteDropdownState extends State<RemoteDropdown> {
  late final ValueNotifier<String> _urlNotifier;

  @override
  void initState() {
    super.initState();
    _urlNotifier = ValueNotifier<String>(Host.url);
  }
  
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: _urlNotifier,
      builder: (context, url, child) {
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
                      Provider.of<Model>(context, listen: false).setParameter("remote_model", value);
                    }
                  },
                  width: 200,
                );
              },
            ),
          ],
        )
      );
    });
  }

  @override
  void dispose() {
    _urlNotifier.dispose();
    super.dispose();
  }
}