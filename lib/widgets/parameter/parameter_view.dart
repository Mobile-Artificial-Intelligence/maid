part of 'package:maid/main.dart';

class ParameterView extends StatefulWidget {
  const ParameterView({super.key});

  @override
  State<ParameterView> createState() => ParameterViewState();
}

class ParameterViewState extends State<ParameterView> {
  Timer? timer;
  Map<String,dynamic> parameters = {};
  int count = 0;

  @override
  void initState() {
    super.initState();
    parameters.addAll(ArtificialIntelligenceController.instance.overrides);
    count = parameters.length;
    timer = Timer.periodic(const Duration(seconds: 2), (_) => save());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void save() {
    if (ArtificialIntelligenceController.instance.overrides.length == parameters.length && ArtificialIntelligenceController.instance.overrides.entries.every((entry) => parameters[entry.key] == entry.value)) {
      return;
    }

    ArtificialIntelligenceController.instance.overrides = Map.from(parameters);
  }

  void import() async {
    final inputFile = await FilePicker.platform.pickFiles(
      dialogTitle: 'Import Parameters',
      type: FileType.custom,
      allowedExtensions: ['json']
    );

    if (inputFile != null) {
      final bytes = inputFile.files.single.bytes ?? File(inputFile.files.single.path!).readAsBytesSync();
      final parameterString = utf8.decode(bytes);

      parameters = jsonDecode(parameterString);
      count = parameters.length;
      
      setState(() {});
      save();
    }
  }

  void export() async {
    final parameterString = jsonEncode(parameters);

    final outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Export Parameters',
      fileName: 'parameters.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: utf8.encode(parameterString)
    );

    if (outputFile != null && !File(outputFile).existsSync()) {
      await File(outputFile).writeAsString(parameterString);
    }
  }

  void onChange(String oldKey, [String? newKey, dynamic newValue]) {
    // restart the timer
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 2), (_) => save());

    if (newKey == null) {
      count -= 1;
    }

    if (oldKey.isNotEmpty) {
      parameters.remove(oldKey);
    }

    if (newKey != null && newKey.isNotEmpty && newValue != null) {
      parameters[newKey] = newValue;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      Text(
        AppLocalizations.of(context)!.modelParameters,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      buildActionsRow(),
      const SizedBox(height: 8),
    ];

    for (int i = 0; i < count; i++) {
      children.add(Parameter(
        overrideKey: parameters.keys.length > i ? parameters.keys.elementAt(i) : null,
        overrideValue: parameters.values.length > i ? parameters.values.elementAt(i) : null,
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
        onPressed: () => setState(() => count += 1), 
        child: Text(AppLocalizations.of(context)!.addParameter)
      ),
      ElevatedButton(
        onPressed: save, 
        child: Text(AppLocalizations.of(context)!.saveParameters)
      ),
      ElevatedButton(
        onPressed: import, 
        child: Text(AppLocalizations.of(context)!.importParameters)
      ),
      ElevatedButton(
        onPressed: export, 
        child: Text(AppLocalizations.of(context)!.exportParameters)
      ),
    ]
  ); 
}