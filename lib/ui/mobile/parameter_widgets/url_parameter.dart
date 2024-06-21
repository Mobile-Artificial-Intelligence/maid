import 'package:flutter/material.dart';
import 'package:maid/classes/providers/large_language_model.dart';

class UrlParameter extends StatefulWidget {
  const UrlParameter({super.key});

  @override
  State<UrlParameter> createState() => _UrlParameterState();
}

class _UrlParameterState extends State<UrlParameter> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    controller.text = LargeLanguageModel.of(context).uri;

    return ListTile(
      title: Row(
        children: [
          const Expanded(
            child: Text("URL"),
          ),
          IconButton(
            onPressed: () async {
              await LargeLanguageModel.of(context).resetUri();
              setState(() {
                controller.text = LargeLanguageModel.of(context).uri;
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
                LargeLanguageModel.of(context).uri = value;
              },
            ),
          ),
        ],
      ),
    );
  }
}
