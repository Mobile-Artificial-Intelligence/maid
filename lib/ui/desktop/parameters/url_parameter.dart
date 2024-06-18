import 'package:flutter/material.dart';
import 'package:maid/classes/large_language_model.dart';

class UrlParameter extends StatefulWidget {
  const UrlParameter({super.key});

  @override
  State<UrlParameter> createState() => _UrlParameterState();
}

class _UrlParameterState extends State<UrlParameter> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.3,
      ),
      child: buildColumn(context),
    );
  }

  Widget buildColumn(BuildContext context) {
    return Column(
      children: [
        const Text("URL"),
        const SizedBox(height: 5.0),
        buildRow(context)
      ],
    );
  }

  Widget buildRow(BuildContext context) {
    controller.text = LargeLanguageModel.of(context).uri;

    return Row(
      children: [
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
    );
  }
}
