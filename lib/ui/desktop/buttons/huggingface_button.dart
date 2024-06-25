import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HuggingfaceButton extends StatefulWidget {
  const HuggingfaceButton({super.key});

  @override
  State<HuggingfaceButton> createState() => _HuggingfaceButtonState();
}

class _HuggingfaceButtonState extends State<HuggingfaceButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'HuggingFace',
      onPressed: () => showHuggingfaceDialog(context), 
      icon: SizedBox(
        width: 30.0,
        height: 30.0,
        child: SvgPicture.asset(
          'assets/huggingface-colour.svg',
        ),
      )
    );
  }

  void showHuggingfaceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Select HuggingFace Model',
            textAlign: TextAlign.center
          ),
          content: const Text('This is a HuggingFace button.'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Close"
              ),
            ),
          ],
          actionsAlignment: MainAxisAlignment.center,
        );
      },
    );
  }
}