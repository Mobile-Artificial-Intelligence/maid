import 'package:flutter/material.dart';

class DoubleButtonRow extends StatelessWidget {
  final String leftText;
  final Function() leftOnPressed;
  final String rightText;
  final Function() rightOnPressed;

  const DoubleButtonRow({
    super.key,
    required this.leftText,
    required this.leftOnPressed,
    required this.rightText,
    required this.rightOnPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FilledButton(
          onPressed: leftOnPressed,
          child: Text(
            leftText,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        const SizedBox(width: 10.0),
        FilledButton(
          onPressed: rightOnPressed,
          child: Text(
            rightText,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ],
    );
  }
}