import 'package:flutter/material.dart';

class TextFieldGridTile extends StatelessWidget{
  final String headingText;
  final String labelText;
  final String? initialValue;
  final TextEditingController? controller;
  final bool multiline;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;

  const TextFieldGridTile({super.key, 
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
    return GridTile(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 4,
        children: [
          Text(headingText),
          const SizedBox(height: 5.0),
          TextField(
            keyboardType: multiline ? TextInputType.multiline : TextInputType.text,
            maxLines: multiline ? null : 1,
            cursorColor: Theme.of(context).colorScheme.secondary,
            controller: controller ?? TextEditingController(text: initialValue),
            decoration: InputDecoration(
              labelText: labelText,
            ),
            onSubmitted: onSubmitted,
            onChanged: onChanged,
          )
        ],
      ),
    );
  }
}