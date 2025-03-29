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
      HuggingfaceModel(name: 'llama-2-7b-chat-hf', size: 7.0, parameters: 7.0),
      HuggingfaceModel(name: 'llama-2-13b-chat-hf', size: 13.0, parameters: 13.0),
    ]
  );
}