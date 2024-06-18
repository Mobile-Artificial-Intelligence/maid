import 'package:flutter/material.dart';

class TextFieldContainer extends StatelessWidget{
  final String headingText;
  final String labelText;
  final String? initialValue;
  final TextEditingController? controller;
  final bool multiline;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;

  const TextFieldContainer({super.key, 
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
    );
  }
}