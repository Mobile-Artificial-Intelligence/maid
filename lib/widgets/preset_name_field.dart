import 'package:flutter/material.dart';

Widget presetNameField(TextEditingController controller) {
  return IntrinsicWidth(
    child: TextField(
      controller: controller,
      textAlign: TextAlign.center,
      decoration: const InputDecoration(
        labelText: "Preset Name",
        constraints: BoxConstraints(minWidth: 130.0),
      ),
    ),
  );
}