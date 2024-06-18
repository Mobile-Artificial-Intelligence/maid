import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeBox extends StatelessWidget {
  final String code;

  const CodeBox({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            height: 25,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Code',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 12,
                  ),
                ),
                TextButton.icon(
                  // Use TextButton.icon to integrate text and icon in the same button
                  icon: Icon(Icons.content_paste_rounded, color: Theme.of(context).colorScheme.onPrimary, size: 15),
                  label: Text(
                    'Copy Code',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 12,
                    ),
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Code copied to clipboard!")),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero, // Adjust padding as needed
                    minimumSize: const Size(10, 10), // Adjust size as needed
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: Colors.black,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10.0),
              scrollDirection: Axis.horizontal,  // Allow horizontal scrolling
              child: SelectableText(
                code,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          )
        ],
      )
    );
  }
}
