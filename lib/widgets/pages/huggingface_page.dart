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
    body: buildBody(context),
  );

  Widget buildBody(BuildContext context) => ListView(
    children: [
      HuggingfaceModel(
        name: 'Phi 3 Mini 4K Instruct Q4', 
        repo: 'microsoft/Phi-3-mini-4k-instruct-gguf',
        fileName: 'Phi-3-mini-4k-instruct-q4.gguf',
        parameters: 3.82,
        llama: aiController as LlamaCppController,
      ),
      HuggingfaceModel(
        name: 'Phi 3 Mini 4K Instruct FP16', 
        repo: 'microsoft/Phi-3-mini-4k-instruct-gguf',
        fileName: 'Phi-3-mini-4k-instruct-fp16.gguf',
        parameters: 3.82,
        llama: aiController as LlamaCppController,
      ),
    ]
  );
}