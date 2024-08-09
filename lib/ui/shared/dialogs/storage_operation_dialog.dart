import 'package:flutter/material.dart';
import 'package:maid/ui/shared/dialogs/loading_dialog.dart';

class StorageOperationDialog extends StatelessWidget {
  final Future<String> future;
  final void Function(String)? onComplete;

  const StorageOperationDialog({super.key, required this.future, this.onComplete});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (onComplete != null) {
            onComplete!(snapshot.data!);
          }

          return AlertDialog(
            title: Text(
              snapshot.data!,
              textAlign: TextAlign.center
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
        } else {
          return const LoadingDialog(title: "Storage Operation Pending");
        }
      },
    );
  }
}