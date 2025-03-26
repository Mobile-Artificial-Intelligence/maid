part of 'package:maid/main.dart';

class Parameter extends StatefulWidget {
  final String? overrideKey;
  final dynamic overrideValue;
  final void Function(String, [String?, dynamic]) onChange;

  const Parameter({super.key, this.overrideKey, this.overrideValue, required this.onChange});

  @override
  State<StatefulWidget> createState() => ParameterState();
}

class ParameterState extends State<Parameter> {
  TextEditingController keyController = TextEditingController();
  TextEditingController valueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    keyController.text = widget.overrideKey ?? '';
    valueController.text = widget.overrideValue != null ? widget.overrideValue.toString() : '';
  }

  void onChange() {
    final key = keyController.text;
    final value = valueController.text;

    if (key.isEmpty || value.isEmpty) {
      return;
    }

    final num = int.tryParse(value) ?? double.tryParse(value);
    if (num != null) {
      widget.onChange(widget.overrideKey ?? '', key, num);
      return;
    }

    if (value.contains(RegExp(r'^(true|false)$', caseSensitive: false))) {
      final boolean = value.contains(RegExp(r'^true$', caseSensitive: false));
      widget.onChange(widget.overrideKey ?? '', key, boolean);
      return;
    }

    final map = jsonDecode(value);
    if (map is Map<String, dynamic> || map is List<dynamic>) {
      widget.onChange(widget.overrideKey ?? '', key, map);
      return;
    }

    widget.onChange(widget.overrideKey ?? '', key, value);
  }

  void onDelete() {
    widget.onChange(widget.overrideKey ?? '');
  }

  @override
  Widget build(BuildContext context) => Row(
    children: [
      buildKeyTextField(),
      const SizedBox(width: 8),
      buildValueTextField(),
      IconButton(
        tooltip: AppLocalizations.of(context)!.removeParameter,
        icon: const Icon(Icons.delete),
        onPressed: onDelete,
      ),
    ],
  );

  Widget buildKeyTextField() => Expanded(
    child: TextField(
      controller: keyController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.key,
      ),
      onChanged: (_) => onChange(),
    )
  );

  Widget buildValueTextField() => Expanded(
    child: TextField(
      controller: valueController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.value,
      ),
      onChanged: (_) => onChange(),
    )
  );
}