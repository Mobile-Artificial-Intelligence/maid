  
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

Future<void> switcherDialog(
  BuildContext context, 
  List<String> Function() getMenuStrings, 
  void Function(String) set, 
  void Function() refresh,
  void Function() newPreset
) async {    
  // Create a variable to determine if the dialog is visible
  bool isDialogVisible = true;

  // Define a function to close the dialog if it's visible
  void closeDialog() {
    if (isDialogVisible) {
      Navigator.of(context).pop();
      isDialogVisible = false; // Set the flag to false after closing the dialog
    }
  }
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          "Switch Preset",
          textAlign: TextAlign.center,
        ),
        content: SizedBox(
          height: 200,
          width: 200,
          child: ListView.builder(
            itemCount: getMenuStrings().length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(
                  getMenuStrings()[index],
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  set(getMenuStrings()[index]);
                  closeDialog();
                  refresh();
                },
              );
            },
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              closeDialog();
            },
            child: Text(
              "Cancel",
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          FilledButton(
            onPressed: () {
              newPreset();
              closeDialog();
            },
            child: Text(
              "New Preset",
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      );
    },
  ).then((_) {
    // When the dialog is dismissed, set the flag to false
    isDialogVisible = false;
  });
}