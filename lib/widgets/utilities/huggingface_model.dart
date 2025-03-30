part of 'package:maid/main.dart';

class HuggingfaceModel extends StatefulWidget {
  final String name;
  final String repo;
  final String branch;
  final String fileName;
  final double parameters; // Billions of parameters
  final LlamaCppController llama;

  const HuggingfaceModel({
    super.key, 
    required this.name, 
    required this.repo,
    this.branch = 'main',
    required this.fileName,
    required this.parameters,
    required this.llama,
  });

  @override
  State<HuggingfaceModel> createState() => HuggingfaceModelState();
}

class HuggingfaceModelState extends State<HuggingfaceModel> {
  double size = 0;
  double progress = 0;

  Future<int?> fetchRemoteFileSize() async {
    final url = "https://huggingface.co/${widget.repo}/resolve/${widget.branch}/${widget.fileName}";

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
      widget.fileName,
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
    final filePath = await HuggingfaceManager.getFilePath(widget.fileName);
    widget.llama.removeLoadedModel(filePath);
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      setState(() => progress = 0);
    }
  }

  void selectModel() async {
    final filePath = await HuggingfaceManager.getFilePath(widget.fileName);
    widget.llama.loadModelFile(filePath);
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
    initAsync();
  }

  void initAsync() async {
    final filePath = await HuggingfaceManager.getFilePath(widget.fileName);
    if (File(filePath).existsSync()) {
      final file = File(filePath);
      size = (await file.length()) / (1024 * 1024 * 1024); // Convert to GB
      progress = 1.0;
    }
    else {
      size = (await fetchRemoteFileSize() ?? 0) / (1024 * 1024 * 1024); // Convert to GB
    }

    if (HuggingfaceManager.downloadProgress[widget.fileName] != null) {
      handleProgressStream(HuggingfaceManager.downloadProgress[widget.fileName]!.stream);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceBright,
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: buildColumn(context),
  );

  Widget buildColumn(BuildContext context) => Column(
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

  Widget buildTitle(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
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
        )
      ],
    )
  );
}