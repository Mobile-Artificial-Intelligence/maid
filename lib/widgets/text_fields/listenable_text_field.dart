part of 'package:maid/main.dart';

class ListenableTextField<T> extends StatefulWidget {
  final Listenable listenable;
  final String? Function() selector;
  final void Function(String) onChanged;
  final TextInputType? keyboardType;
  final int? maxLines;
  final String labelText;
  final bool requireSave;

  const ListenableTextField({
    super.key,
    required this.listenable,
    required this.selector,
    required this.onChanged,
    required this.labelText, 
    this.keyboardType, 
    this.maxLines = 1,
    this.requireSave = false
  });

  @override
  State<ListenableTextField<T>> createState() => ListenableTextFieldState<T>();
}

class ListenableTextFieldState<T> extends State<ListenableTextField<T>> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.listenable,
    builder: buildTextField
  );

  Widget buildTextField(BuildContext context, Widget? child) {
    final value = widget.selector();

    if (
      value != null && 
      !controller.text.isSimilar(value)
    ) {
      controller.text = value;
    }
    else if (value == null || value.isEmpty) {
      controller.clear();
    }
    
    return widget.requireSave ? buildWithSave() : buildWithoutSave();
  }

  Widget buildWithoutSave() => TextField(
    decoration: InputDecoration(
      labelText: widget.labelText,
    ),
    controller: controller,
    onChanged: !widget.requireSave ? widget.onChanged : null,
    keyboardType: widget.keyboardType,
    maxLines: widget.maxLines,
  );

  Widget buildWithSave() => Row(
    children: [
      Expanded(child: buildWithoutSave()),
      IconButton(
        tooltip: AppLocalizations.of(context)!.save,
        icon: const Icon(Icons.save),
        onPressed: () => widget.onChanged(controller.text)
      )
    ]
  );
}