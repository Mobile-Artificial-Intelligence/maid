  
import 'package:flutter/material.dart';
import 'package:maid/providers/session.dart';
import 'package:provider/provider.dart';

Future<void> storageOperationDialog(BuildContext context, Future<String> Function(BuildContext context) storageFunction) async {
  String ret = await storageFunction(context);
  // Ensure that the context is still valid before attempting to show the dialog.
  if (context.mounted) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            ret,
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Close",
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ],
        );
      },
    );
  }
}

void showMissingRequirementsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      final requirement = context.read<Session>().model.missingRequirements;

      return AlertDialog(
        title: const Text(
          "Missing Requirements",
          textAlign: TextAlign.center
        ),
        actionsAlignment: MainAxisAlignment.center,
        content: Text(
          requirement.join()
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
    },
  );
}