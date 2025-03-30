part of 'package:maid/main.dart';

class HuggingFacePage extends StatelessWidget {
  const HuggingFacePage({
    super.key, 
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        AppLocalizations.of(context)!.huggingface
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
        size: 1.2, 
        parameters: 7.0
      ),
    ]
  );
}