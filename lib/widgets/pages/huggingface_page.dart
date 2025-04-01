part of 'package:maid/main.dart';

class HuggingFacePage extends StatelessWidget {
  final ArtificialIntelligenceController aiController;

  const HuggingFacePage({
    super.key, 
    required this.aiController,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        AppLocalizations.of(context)!.localModels
      ),
    ),
    body: buildFutureBuilder(context),
  );

  Future<List<Widget>> getModelList() async {
    List<Widget> widgets = [];
    List<dynamic> modelList;

    try {
      // If debug is enabled, load JSON from assets
      if (kDebugMode) throw Exception('Debug mode is enabled, loading from assets');

      // Try to fetch JSON from the web
      final response = await Dio().get(
        'https://raw.githubusercontent.com/Mobile-Artificial-Intelligence/maid/refs/heads/main/huggingface_models.json'
      );

      // Decode the web JSON response
      modelList = jsonDecode(response.data) as List;
    } catch (e) {
      // If web fetch fails, load JSON from assets
      final modelListString = await rootBundle.loadString('huggingface_models.json');
      modelList = jsonDecode(modelListString) as List;
    }

    for (final model in modelList) {
      final modelMap = model as Map<String, dynamic>;

      widgets.add(
        HuggingfaceModel(
          name: modelMap['name'],
          repo: modelMap['repo'],
          parameters: modelMap['parameters'],
          tags: (modelMap['tags'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, value.toString())
          ),
          llama: aiController as LlamaCppController,
        )
      );
    }

    return widgets;
  }

  Widget buildFutureBuilder(BuildContext context) => FutureBuilder(
    future: getModelList(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      else if (snapshot.hasError) {
        return Center(
          child: Text(
            snapshot.error.toString(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        );
      }
      else if (snapshot.hasData) {
        return GridView.extent(
          maxCrossAxisExtent: 500,
          childAspectRatio: 3,
          shrinkWrap: true,
          children: snapshot.data!,
        );
      }

      return const SizedBox();
    },
  );
}