part of 'package:maid/main.dart';

class HuggingFacePage extends StatelessWidget {
  const HuggingFacePage({
    super.key, 
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        'Huggingface' // TODO: Localize
      ),
    ),
    body: buildBody(context),
  );

  Widget buildBody(BuildContext context) => ListView(
    children: [
      ListTile(
        title: Text(
          'Huggingface', // TODO: Localize
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    ]
  );
}