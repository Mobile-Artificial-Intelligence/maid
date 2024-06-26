import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:maid/ui/shared/dialogs/huggingface_dialog.dart';

class HuggingfaceButton extends StatelessWidget {
  const HuggingfaceButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'HuggingFace',
      onPressed: () => showDialog(
        context: context,
        builder: (BuildContext context) => const HuggingfaceDialog(),
      ), 
      icon: SizedBox(
        width: 30.0,
        height: 30.0,
        child: SvgPicture.asset(
          'assets/huggingface-colour.svg',
        ),
      )
    );
  }
}