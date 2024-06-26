import 'package:flutter/material.dart';
import 'package:maid/classes/providers/large_language_models/llama_cpp_model.dart';
import 'package:maid/ui/shared/buttons/huggingface_button.dart';
import 'package:maid/ui/shared/buttons/load_model_button.dart';

class LlamaCppModelControls extends StatelessWidget {
  const LlamaCppModelControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const HuggingfaceButton(),
        const Expanded(
          flex: 1,
          child: LoadModelButton(),
        ),
        IconButton(
          tooltip: "Eject Model",
          onPressed: () {
            LlamaCppModel.of(context).resetUri();
            LlamaCppModel.of(context).name = "";
          },
          icon: const Icon(Icons.eject_rounded),
        )
      ]
    );
  }
}