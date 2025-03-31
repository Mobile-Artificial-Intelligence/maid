part of 'package:maid/main.dart';

class HuggingfaceModel extends StatefulWidget {
  final String name;
  final String repo;
  final String branch;
  final double parameters; // Billions of parameters
  final Map<String, String> tags;
  final LlamaCppController llama;

  const HuggingfaceModel({
    super.key, 
    required this.name, 
    required this.repo,
    this.branch = 'main',
    required this.parameters,
    required this.tags,
    required this.llama,
  });

  @override
  State<HuggingfaceModel> createState() => HuggingfaceModelState();
}

class HuggingfaceModelState extends State<HuggingfaceModel> {
  static final Map<String, double> sizeCache = {};
  bool tagDropdownOpen = false;
  MapEntry<String, String>? tag;
  double size = 0;
  double progress = 0;

  Future<int?> fetchRemoteFileSize() async {
    final url = "https://huggingface.co/${widget.repo}/resolve/${widget.branch}/${tag!.value}";

    try {
      final response = await Dio().head(url, options: Options(
        followRedirects: true,
        validateStatus: (status) => status! < 500,
      ));

      final contentLength = response.headers.value(HttpHeaders.contentLengthHeader);
      if (contentLength != null) {
        return int.tryParse(contentLength);
      }
    } catch (e) {
      debugPrint("Failed to fetch file size: $e");
    }

    return null;
  }

  void downloadModel() async {
    setState(() => progress = 0);

    handleProgressStream(HuggingfaceManager.download(
      widget.repo,
      widget.branch,
      tag!.value,
      widget.llama
    ));
  }

  void handleProgressStream(Stream<double> stream) {
    stream.listen(
      (event) {
        if (!mounted) return;
        setState(() => progress = event);
      },
      onDone: () {
        if (!mounted) return;
        setState(() => progress = 1);
      },
      onError: (error) {
        debugPrint("Error downloading model: $error");
        if (!mounted) return;
        setState(() => progress = 0);
      }
    );
  }

  void deleteModel() async {
    final filePath = await HuggingfaceManager.getFilePath(tag!.value);
    widget.llama.removeLoadedModel(filePath);
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      setState(() => progress = 0);
    }
  }

  void selectModel() async {
    final filePath = await HuggingfaceManager.getFilePath(tag!.value);
    widget.llama.loadModelFile(filePath, true);
  }

  void exportModel() async {
    final filePath = await HuggingfaceManager.getFilePath(tag!.value);
    final file = File(filePath);

    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Export Model',
      fileName: tag!.value,
      type: FileType.custom,
      allowedExtensions: ['gguf']
    );

    if (outputPath != null) {
      await file.copy(outputPath);
    }
  }

  void navigateRepo() async {
    final url = Uri.parse('https://huggingface.co/${widget.repo}');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      final key = prefs.getString(widget.repo);

      if (key != null) {
        tag = widget.tags.entries.firstWhere(
          (entry) => entry.key == key,
          orElse: () => widget.tags.entries.first
        );
      } 
      else {
        tag = widget.tags.entries.first;
      }

      handleTagChange(tag!);

      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.all(4.0),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceBright,
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 600,
          maxHeight: 200
        ),
        child: buildColumn(context),
      ),
    ),
  );

  Widget buildColumn(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildTitle(context),
      Text(
        '${AppLocalizations.of(context)!.size}: ${size.toStringAsFixed(2)} GB',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      Text(
        '${AppLocalizations.of(context)!.parameters}: ${widget.parameters.toString()} B',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      buildProgressIndicator(context),
      progress == 1
        ? buildActionsRow(context)
        : buildDownloadButton(context),
    ],
  );

  Widget buildDownloadButton(BuildContext context) => Center(
    child: TextButton.icon(
      onPressed: progress == 0 ? downloadModel : null,
      label: Text(
        AppLocalizations.of(context)!.downloadModel,
        style: progress == 0
          ? Theme.of(context).textTheme.labelMedium
          : Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
      ),
      icon: Icon(
        Icons.download,
        color: progress == 0
          ? Theme.of(context).colorScheme.onSurface
          : Theme.of(context).colorScheme.outline,
      ),
    )
  );

  Widget buildActionsRow(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      TextButton.icon(
        onPressed: deleteModel,
        label: Text(
          AppLocalizations.of(context)!.delete,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        icon: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.error,
        ),
      ),
      if (TargetPlatformExtension.isDesktop) TextButton.icon(
        onPressed: exportModel,
        label: Text(
          AppLocalizations.of(context)!.export,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        icon: Icon(
          Icons.save,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      TextButton.icon(
        onPressed: selectModel,
        label: Text(
          AppLocalizations.of(context)!.select,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        icon: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      )
    ],
  );

  Widget buildProgressIndicator(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: LinearProgressIndicator(
      value: progress,
      minHeight: 5,
      borderRadius: BorderRadius.circular(5),
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.outline,
    )
  );

  Widget buildTitle(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Text(
        widget.name,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      IconButton(
        onPressed: navigateRepo,
        iconSize: 20,
        icon: Icon(
          Icons.launch,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      const Spacer(),
      Text(
        tag?.key ?? AppLocalizations.of(context)!.selectTag,
        style: Theme.of(context).textTheme.labelMedium,
      ),
      PopupMenuButton<MapEntry<String, String>>(
        tooltip: AppLocalizations.of(context)!.selectTag,
        icon: Icon(
          tagDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        offset: const Offset(0, 40),
        itemBuilder: tagMenuItemBuilder,
        onOpened: () => setState(() => tagDropdownOpen = true),
        onCanceled: () => setState(() => tagDropdownOpen = false),
        onSelected: handleTagChange
      )
    ],
  );

  List<PopupMenuEntry<MapEntry<String, String>>> tagMenuItemBuilder(BuildContext context) => widget.tags.entries.map(tagMenuMapper).toList();

  PopupMenuItem<MapEntry<String, String>> tagMenuMapper(MapEntry<String, String> entry) => PopupMenuItem<MapEntry<String, String>>(
    value: entry,
    child: Text(entry.key),
  );

  void handleTagChange(MapEntry<String, String> entry) async {
    setState(() {
      progress = 0;
      tag = entry;
      tagDropdownOpen = false;
    });

    final prefs = await SharedPreferences.getInstance();
    prefs.setString(widget.repo, entry.key);

    final filePath = await HuggingfaceManager.getFilePath(entry.value);
    if (File(filePath).existsSync()) {
      final file = File(filePath);
      size = (await file.length()) / (1024 * 1024 * 1024); // Convert to GB
      progress = 1.0;
    }
    else if (sizeCache[entry.value] != null) {
      size = sizeCache[entry.value]!;
    } 
    else {
      size = (await fetchRemoteFileSize() ?? 0) / (1024 * 1024 * 1024); // Convert to GB
    }
    sizeCache[entry.value] = size;

    if (HuggingfaceManager.downloadProgress[entry.value] != null) {
      handleProgressStream(HuggingfaceManager.downloadProgress[entry.value]!.stream);
    }

    if (mounted) setState(() {});
  }
}