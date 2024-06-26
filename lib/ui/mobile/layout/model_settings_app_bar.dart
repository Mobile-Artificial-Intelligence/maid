import 'package:flutter/material.dart';
import 'package:maid/classes/providers/large_language_model.dart';

class ModelSettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  
  const ModelSettingsAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: Text(title),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            tooltip: "Reset Model",
            icon: const Icon(Icons.refresh),
            onPressed: LargeLanguageModel.of(context).reset,
          ),
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}