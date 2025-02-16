part of 'package:maid/main.dart';

class OverrideTypeDropdown extends StatefulWidget {
  final OverrideType initialValue;
  final void Function(OverrideType) onChanged;
  
  const OverrideTypeDropdown({super.key, required this.onChanged, required this.initialValue});

  @override
  State<OverrideTypeDropdown> createState() => _OverrideTypeDropdownState();
}

class _OverrideTypeDropdownState extends State<OverrideTypeDropdown> {
  OverrideType overrideType = OverrideType.string;
  bool open = false;

  @override
  void initState() {
    super.initState();
    overrideType = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const SizedBox(width: 8),
      buildOverrideText(),
      buildPopupButton()
    ]
  );

  Widget buildOverrideText() => Text(
    overrideType.name.firstCapitalized,
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 16
    )
  );

  Widget buildPopupButton() => PopupMenuButton<OverrideType>(
    tooltip: 'Select Override Type',
    icon: Icon(
      open ? Icons.arrow_drop_up : Icons.arrow_drop_down,
      color: Theme.of(context).colorScheme.onSurface,
      size: 24,
    ),
    offset: const Offset(0, 40),
    itemBuilder: itemBuilder,
    onOpened: () => setState(() => open = true),
    onCanceled: () => setState(() => open = false),
    onSelected: (themeMode) {
      widget.onChanged(themeMode);
      setState(() {
        open = false;
        overrideType = themeMode;
      });
    }
  );

  List<PopupMenuEntry<OverrideType>> itemBuilder(BuildContext context) => [
    PopupMenuItem(
      padding: EdgeInsets.all(8),
      value: OverrideType.string,
      child: const Text('String')
    ),
    PopupMenuItem(
      padding: EdgeInsets.all(8),
      value: OverrideType.int,
      child: const Text('Int')
    ),
    PopupMenuItem(
      padding: EdgeInsets.all(8),
      value: OverrideType.double,
      child: const Text('Double')
    ),
    PopupMenuItem(
      padding: EdgeInsets.all(8),
      value: OverrideType.bool,
      child: const Text('Bool')
    ),
    PopupMenuItem(
      padding: EdgeInsets.all(8),
      value: OverrideType.json,
      child: const Text('Json')
    ),
  ];
}