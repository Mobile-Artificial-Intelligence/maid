part of 'package:maid/main.dart';

class ParameterView extends StatefulWidget {
  final ArtificialIntelligenceController aiController;
  
  const ParameterView({
    super.key, 
    required this.aiController
  });

  @override
  State<ParameterView> createState() => ParameterViewState();
}

class ParameterViewState extends State<ParameterView> {
  Timer? timer;
  Map<String,dynamic> overrides = {};
  int overrideCount = 0;

  @override
  void initState() {
    super.initState();
    overrides.addAll(widget.aiController.overrides);
    overrideCount = overrides.length;
    timer = Timer.periodic(const Duration(seconds: 2), (_) => save());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void save() {
    if (widget.aiController.overrides.length == overrides.length && widget.aiController.overrides.entries.every((entry) => overrides[entry.key] == entry.value)) {
      return;
    }

    widget.aiController.overrides = Map.from(overrides);
  }

  void onChange(String oldKey, [String? newKey, dynamic newValue]) {
    // restart the timer
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 2), (_) => save());

    if (newKey == null) {
      overrideCount -= 1;
    }

    if (oldKey.isNotEmpty) {
      overrides.remove(oldKey);
    }

    if (newKey != null && newKey.isNotEmpty && newValue != null) {
      overrides[newKey] = newValue;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      Text(
        AppLocalizations.of(context)!.inferanceOverrides,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      buildActionsRow(),
      const SizedBox(height: 8),
    ];

    for (int i = 0; i < overrideCount; i++) {
      children.add(Parameter(
        overrideKey: overrides.keys.length > i ? overrides.keys.elementAt(i) : null,
        overrideValue: overrides.values.length > i ? overrides.values.elementAt(i) : null,
        onChange: onChange,
      ));
    }

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: children,
    );
  }

  Widget buildActionsRow() => Wrap(
    alignment: WrapAlignment.center,
    runAlignment: WrapAlignment.center,
    spacing: 16,
    runSpacing: 16,
    children: [
      ElevatedButton(
        onPressed: () => setState(() => overrideCount += 1), 
        child: Text(AppLocalizations.of(context)!.addOverride)
      ),
      ElevatedButton(
        onPressed: save, 
        child: Text(AppLocalizations.of(context)!.saveOverride)
      ),
    ]
  ); 
}