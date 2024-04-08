import 'package:flutter/material.dart';
import 'package:maid/providers/session.dart';
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
    controller.text = context.read<Session>().model.uri;

    return ListTile(
      title: Row(
        children: [
          const Expanded(
            child: Text("URL"),
          ),
          IconButton(
            onPressed: () async {
              final model = context.read<Session>().model;
              await model.resetUri();
              controller.text = model.uri;
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
                context.read<Session>().model.uri = value;
              },
            ),
          ),
        ],
      ),
    );
  }
}
