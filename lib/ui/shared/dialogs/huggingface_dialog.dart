import 'package:flutter/material.dart';
import 'package:maid/classes/providers/huggingface_selection.dart';
import 'package:maid/classes/providers/large_language_models/llama_cpp_model.dart';
import 'package:maid/ui/shared/dialogs/loading_dialog.dart';
import 'package:maid/ui/shared/dropdowns/huggingface_model_dropdown.dart';
import 'package:provider/provider.dart';

class HuggingfaceDialog extends StatelessWidget {
  const HuggingfaceDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HuggingfaceSelection>(
      builder: (context, huggingfaceSelection, child) {
        if (huggingfaceSelection.progress != null) {
          return const LoadingDialog(title: "Downloading Model");
        }

        return AlertDialog(
          title: const Text(
            'Select HuggingFace Model',
            textAlign: TextAlign.center
          ),
          content: const HuggingfaceModelDropdown(),
          actions: [
            buildDeleteButton(huggingfaceSelection),
            buildSelectButton(huggingfaceSelection),
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
    );
  }

  Widget buildDeleteButton(HuggingfaceSelection huggingfaceSelection) {
    return FutureBuilder(
      future: huggingfaceSelection.alreadyExists, 
      builder: buildDeleteButtonFuture,
    );
  }

  Widget buildDeleteButtonFuture(BuildContext context, AsyncSnapshot<bool> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      if (!(snapshot.data as bool)) {
        return const SizedBox.shrink();
      }

      return FilledButton(
        onPressed: () {
          HuggingfaceSelection.of(context).delete();
        },
        child: const Text(
          "Delete"
        ),
      );
    }
    else {
      return const CircularProgressIndicator();
    }
  }

  Widget buildSelectButton(HuggingfaceSelection huggingfaceSelection) {
    return FutureBuilder(
      future: huggingfaceSelection.alreadyExists, 
      builder: buildSelectButtonFuture,
    );
  }

  Widget buildSelectButtonFuture(BuildContext context, AsyncSnapshot<bool> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      return FilledButton(
        onPressed: () {
          final future = HuggingfaceSelection.of(context).download();
          LlamaCppModel.of(context).setModelWithFuture(future);
          Navigator.of(context).pop();
        },
        child: Text(
          (snapshot.data as bool) ? "Select" : "Download"
        ),
      );
    }
    else {
      return const CircularProgressIndicator();
    }
  }
}