  
import 'package:flutter/material.dart';
import 'package:maid/utilities/memory_manager.dart';

Future<void> storageOperationDialog(BuildContext context, Future<String> Function(BuildContext context) storageFunction) async {
  String ret = await storageFunction(context);
  // Ensure that the context is still valid before attempting to show the dialog.
  if (context.mounted) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(ret),
          alignment: Alignment.center,
          actionsAlignment: MainAxisAlignment.center,
          backgroundColor: Theme.of(context).colorScheme.background,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          actions: [
            FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  MemoryManager.save();
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