import 'package:flutter/material.dart';

class SliderGridTile extends StatelessWidget {
  final String labelText;
  final num inputValue;
  final double sliderMin;
  final double sliderMax;
  final int sliderDivisions;
  final Function(double) onValueChanged;

  const SliderGridTile({
    super.key,
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
    TextEditingController textController = TextEditingController(
      text: inputValue.toString(),
    );

    // I finput value is a double
    if (inputValue is int) {
      // If input value is an integer
      labelValue = inputValue.round().toString();
    } else {
      labelValue = inputValue.toStringAsFixed(3);
    }

    return GridTile(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceDim,
          borderRadius: BorderRadius.circular(8.0)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(labelText),
            Flexible(
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
            Flexible(
              child: TextFormField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                controller: textController,
                onEditingComplete: () {
                  final parsedValue =
                      double.tryParse(textController.text) ?? sliderMin;
                  if (parsedValue < sliderMin) {
                    onValueChanged(sliderMin);
                  } else if (parsedValue > sliderMax) {
                    onValueChanged(sliderMax);
                  } else {
                    onValueChanged(parsedValue);
                  }
                },
              ),
            )
          ],
        )
      ),
    );
  }
}
