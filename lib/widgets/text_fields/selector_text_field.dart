part of 'package:maid/main.dart';

class SelectorTextField<T> extends StatelessWidget {
  final TextEditingController controller = TextEditingController();
  final String? Function(BuildContext, T) selector;
  final void Function(String) onChanged;
  final TextInputType? keyboardType;
  final int? maxLines;
  final String labelText;

  SelectorTextField({
    super.key,
    required this.selector,
    required this.onChanged,
    required this.labelText, 
    this.keyboardType, 
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => Selector<T, String?>(
    selector: selector,
    builder: buildTextField
  );

  Widget buildTextField(BuildContext context, String? value, Widget? child) {
    if (
      value != null && 
      !controller.text.isSimilar(value)
    ) {
      controller.text = value;
    }
    
    return TextField(
      decoration: InputDecoration(
        labelText: labelText,
      ),
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }
}