import 'package:flutter/material.dart';

class TextFieldListTile extends StatelessWidget {
  final String headingText;
  final String labelText;
  final String? initialValue;
  final TextEditingController? controller;
  final bool multiline;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;

  const TextFieldListTile({
    super.key,
    required this.headingText,
    required this.labelText,
    this.initialValue,
    this.controller,
    this.multiline = false,
    this.onSubmitted,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align the text to the start
        children: [
          Semantics(
            label: 'Heading',
            child: Text(headingText),
          ),
          const SizedBox(height: 5.0),
          Semantics(
            label: labelText,
            hint: multiline ? 'Multi-line text input' : 'Single-line text input',
            child: TextField(
              keyboardType: multiline ? TextInputType.multiline : TextInputType.text,
              maxLines: multiline ? null : 1,
              cursorColor: Theme.of(context).colorScheme.secondary,
              controller: controller ?? TextEditingController(text: initialValue),
              decoration: InputDecoration(
                labelText: labelText,
              ),
              onSubmitted: onSubmitted,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
