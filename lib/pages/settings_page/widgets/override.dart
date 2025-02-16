part of 'package:maid/main.dart';

class Override extends StatefulWidget {
  final String? overrideKey;
  final dynamic overrideValue;
  final void Function(String, [String?, dynamic]) onChange;

  const Override({super.key, this.overrideKey, this.overrideValue, required this.onChange});

  @override
  State<StatefulWidget> createState() => OverrideState();
}

class OverrideState extends State<Override> {
  OverrideType overrideType = OverrideType.string;
  TextEditingController keyController = TextEditingController();
  TextEditingController valueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.overrideValue is int) {
      overrideType = OverrideType.int;
    } 
    else if (widget.overrideValue is double) {
      overrideType = OverrideType.double;
    } 
    else if (widget.overrideValue is bool) {
      overrideType = OverrideType.bool;
    } 
    else if (widget.overrideValue is Map<String, dynamic>) {
      overrideType = OverrideType.json;
    }

    keyController.text = widget.overrideKey ?? '';
    valueController.text = widget.overrideValue != null ? widget.overrideValue.toString() : '';
  }

  void onChange() {
    final key = keyController.text;
    dynamic value = valueController.text;

    if (key.isEmpty) {
      return;
    }

    switch (overrideType) {
      case OverrideType.int:
        value = int.tryParse(value);
        break;
      case OverrideType.double:
        value = double.tryParse(value);
        break;
      case OverrideType.bool:
        value = value.toLowerCase() == 'true';
        break;
      case OverrideType.json:
        value = jsonDecode(value);
        break;
      default:
        break;
    }

    if (value == null || (value is String && value.isEmpty)) {
      return;
    }

    widget.onChange(widget.overrideKey ?? '', key, value);
  }

  void onDelete() {
    widget.onChange(widget.overrideKey ?? '');
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(8),
    child: buildRow(),
  );
  
  Widget buildRow() => Row(
    children: [
      IconButton(
        icon: const Icon(Icons.delete),
        onPressed: onDelete,
      ),
      buildKeyTextField(),
      OverrideTypeDropdown(
        onChanged: (type) => setState(() => overrideType = type), 
        initialValue: overrideType
      ),
      overrideType == OverrideType.bool ? buildBoolSwitch() : buildValueTextField(),
    ],
  );

  Widget buildBoolSwitch() => Switch(
    value: widget.overrideValue as bool? ?? false,
    onChanged: (value) => widget.onChange(widget.overrideKey ?? '', keyController.text, value),
  );

  Widget buildKeyTextField() => Expanded(
    child: TextField(
      controller: keyController,
      decoration: const InputDecoration(
        labelText: 'Key',
      ),
      onChanged: (_) => onChange(),
    )
  );

  Widget buildValueTextField() => Expanded(
    child: TextField(
      controller: valueController,
      decoration: const InputDecoration(
        labelText: 'Value',
      ),
      onChanged: (_) => onChange(),
    )
  );
}