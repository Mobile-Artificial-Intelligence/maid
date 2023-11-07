  
import 'package:flutter/material.dart';
import 'package:maid/utilities/memory_manager.dart';

class MaidTextField extends StatelessWidget{
  final String labelText;
  final TextEditingController controller;

  const MaidTextField({super.key, 
    required this.labelText,
    required this.controller,
  });

  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: Text(labelText),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              cursorColor: Theme.of(context).colorScheme.secondary,
              controller: controller,
              decoration: InputDecoration(
                labelText: labelText,
              )
            ),
          ),
        ],
      ),
    );
  }
}

Widget settingsSlider(String labelText, num inputValue, 
  double sliderMin, double sliderMax, int sliderDivisions, 
  Function(double) onValueChanged
) {
  String labelValue;

  // I finput value is a double
  if (inputValue is int) {
    // If input value is an integer
    labelValue = inputValue.round().toString();
  } else {
    labelValue = inputValue.toStringAsFixed(3);
  }
  
  return ListTile(
    title: Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(labelText),
        ),
        Expanded(
          flex: 7,
          child: Slider(
            value: inputValue.toDouble(),
            min: sliderMin,
            max: sliderMax,
            divisions: sliderDivisions,
            label: labelValue,
            onChanged: (double value) {
              onValueChanged(value);
            },
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(labelValue),
        ),
      ],
    ),
  );
}

Widget doubleButtonRow(BuildContext context, String leftText, Function() leftOnPressed, String rightText, Function() rightOnPressed) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      FilledButton(
        onPressed: leftOnPressed,
        child: Text(
          leftText,
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ),
      const SizedBox(width: 10.0),
      FilledButton(
        onPressed: rightOnPressed,
        child: Text(
          rightText,
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ),
    ],
  );
}

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
                  memoryManager.save();
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