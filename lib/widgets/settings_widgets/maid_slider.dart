import 'package:flutter/material.dart';

class MaidSlider extends StatelessWidget{
  final String labelText;
  final num inputValue;
  final double sliderMin;
  final double sliderMax;
  final int sliderDivisions;
  final Function(double) onValueChanged;

  const MaidSlider({super.key, 
    required this.labelText,
    required this.inputValue,
    required this.sliderMin,
    required this.sliderMax,
    required this.sliderDivisions,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
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
}