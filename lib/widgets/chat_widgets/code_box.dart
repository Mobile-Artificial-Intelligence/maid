import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeBox extends StatelessWidget {
  final String code;

  const CodeBox({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(5),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,  // Allow horizontal scrolling
              child: Row(
                children: [
                  SelectableText(
                    code,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace'
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.copy, color: Theme.of(context).colorScheme.secondary),
          onPressed: () async {
            final ctx = context;
            Clipboard.setData(ClipboardData(text: code)).then((_) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text("Code copied to clipboard!")),
              );
            });
          },
          tooltip: 'Copy Code',
        ),
      ],
    );
  }
}