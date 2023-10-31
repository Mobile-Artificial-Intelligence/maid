  
import 'package:flutter/material.dart';

Widget settingsTextField(String labelText, TextEditingController controller) {
  return ListTile(
    title: Row(
      children: [
        Expanded(
          child: Text(labelText),
        ),
        Expanded(
          flex: 2,
          child: TextField(
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