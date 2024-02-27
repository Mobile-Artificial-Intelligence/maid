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
            child: Row( // Wrap IconButton in a Row
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Code',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                IconButton(
                  iconSize: 15,
                  icon: Icon(Icons.copy, color: Theme.of(context).colorScheme.secondary),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Code copied to clipboard!")),
                    );
                  },
                  tooltip: 'Copy Code',
                  padding: EdgeInsets.zero, // Optional: reduces the padding if needed
                ),
              ],
            ),
          ),
          Container(
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
      ),
    );
  }
}
