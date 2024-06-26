import 'package:flutter/material.dart';
import 'package:maid/classes/providers/large_language_model.dart';

class MissingRequirementsDialog extends StatelessWidget {
  const MissingRequirementsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Missing Requirements",
        textAlign: TextAlign.center
      ),
      actionsAlignment: MainAxisAlignment.center,
      content: Text(
        LargeLanguageModel.of(context).missingRequirements.join()
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            "OK",
            style: Theme.of(context).textTheme.labelLarge
          ),
        ),
      ],
    );
  }
}