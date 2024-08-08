import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:provider/provider.dart';

class UserNameDialog extends StatelessWidget {
  const UserNameDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: dialogBuilder,
    );
  }

  Widget dialogBuilder(BuildContext context, AppData appData, Widget? child) {
    final controller = TextEditingController(text: appData.user.name);

    return AlertDialog(
      title: const Text(
        "Rename User",
        textAlign: TextAlign.center,
      ),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: "Enter new name",
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            "Cancel"
          ),
        ),
        FilledButton(
          onPressed: () {
            appData.user.name = controller.text;
            Navigator.of(context).pop();
          },
          child: const Text(
            "Rename"
          ),
        ),
      ],
    );
  }
}