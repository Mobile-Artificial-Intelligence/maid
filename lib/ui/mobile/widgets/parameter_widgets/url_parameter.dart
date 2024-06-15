import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:provider/provider.dart';

class UrlParameter extends StatefulWidget {
  const UrlParameter({super.key});

  @override
  State<UrlParameter> createState() => _UrlParameterState();
}

class _UrlParameterState extends State<UrlParameter> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final model = context.read<AppData>().currentSession.model;
    controller.text = model.uri;

    return ListTile(
      title: Row(
        children: [
          const Expanded(
            child: Text("URL"),
          ),
          IconButton(
            onPressed: () async {
              await model.resetUri();
              setState(() {
                controller.text = model.uri;
              });
            }, 
            icon: const Icon(Icons.refresh),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              keyboardType: TextInputType.text,
              maxLines: 1,
              cursorColor: Theme.of(context).colorScheme.secondary,
              controller: controller,
              decoration: const InputDecoration(
                labelText: "URL",
              ),
              onChanged: (value) {
                model.uri = value;
              },
            ),
          ),
        ],
      ),
    );
  }
}
