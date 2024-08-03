import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:maid/classes/providers/user.dart';
import 'package:provider/provider.dart';

class UserNameDialog extends StatelessWidget {
  const UserNameDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AppData, User>(
      selector: (context, appData) => appData.user,
      builder: dialogBuilder,
    );
  }

  Widget dialogBuilder(BuildContext context, User user, Widget? child) {
    final controller = TextEditingController(text: user.name);

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
            user.name = controller.text;
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