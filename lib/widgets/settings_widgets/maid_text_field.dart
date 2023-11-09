import 'package:flutter/material.dart';
import 'package:maid/utilities/memory_manager.dart';

class MaidTextField extends StatelessWidget{
  final String labelText;
  final TextEditingController controller;
  final bool multiline;

  const MaidTextField({super.key, 
    required this.labelText,
    required this.controller,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: Text(labelText),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              keyboardType: multiline ? TextInputType.multiline : TextInputType.text,
              maxLines: multiline ? null : 1,
              cursorColor: Theme.of(context).colorScheme.secondary,
              controller: controller,
              decoration: InputDecoration(
                labelText: labelText,
              ),
              onSubmitted: (value) => MemoryManager.save(),
            ),
          ),
        ],
      ),
    );
  }
}