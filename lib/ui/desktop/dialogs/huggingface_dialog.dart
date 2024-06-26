import 'package:flutter/material.dart';
import 'package:maid/classes/providers/huggingface_selection.dart';
import 'package:maid/classes/providers/large_language_models/llama_cpp_model.dart';
import 'package:maid/ui/desktop/dropdowns/huggingface_model_dropdown.dart';
import 'package:provider/provider.dart';

class HuggingfaceDialog extends StatelessWidget {
  const HuggingfaceDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Select HuggingFace Model',
        textAlign: TextAlign.center
      ),
      content: const HuggingfaceModelDropdown(),
      actions: [
        buildButton(),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            "Close"
          ),
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
    );
  }

  Widget buildButton() {
    return Consumer<HuggingfaceSelection>(
      builder: (context, huggingfaceSelection, child) {
        return FutureBuilder(
          future: huggingfaceSelection.alreadyExists, 
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (!snapshot.data!) {
                return buildDownloadButton(context, huggingfaceSelection);
              }
              else {
                return buildSelectButton(context, huggingfaceSelection);
              }
            }
            else {
              return const CircularProgressIndicator();
            }
          },
        );
      },
    );
  }

  Widget buildDownloadButton(BuildContext context, HuggingfaceSelection huggingfaceSelection) {
    return FilledButton(
      onPressed: () {
        huggingfaceSelection.download();
        Navigator.of(context).pop();
      },
      child: const Text(
        "Download"
      ),
    );
  }

  Widget buildSelectButton(BuildContext context, HuggingfaceSelection huggingfaceSelection) {
    return FilledButton(
      onPressed: () {
        LlamaCppModel.of(context).uri = huggingfaceSelection.filePath!;
        LlamaCppModel.of(context).name = huggingfaceSelection.tagValue!;
        Navigator.of(context).pop();
      },
      child: const Text(
        "Select"
      ),
    );
  }
}