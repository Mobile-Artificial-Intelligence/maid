part of 'package:maid/main.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text("About"),
    ),
    body: buildBody(context),
  );

  Widget buildBody(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: buildColumn(context)
  );

  Widget buildColumn(BuildContext context) => Column(
    children: [
      const SizedBox(height: 20.0),
      Image.asset(
        "images/logo.png",
        width: 150,
        height: 150,
      ),
      const SizedBox(height: 30.0),
      Text(
        'Maid',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 20.0),
      Text(
        'Maid is an cross-platform free and open source application for interfacing '
        'with llama.cpp models locally, and remotely with Ollama, Mistral, Google '
        'Gemini and OpenAI models remotely. Maid supports sillytavern character '
        'cards to allow you to interact with all your favorite characters. Maid '
        'supports downloading a curated list of Models in-app directly from huggingface. '
        'Maid is distributed under the MIT licence and is provided without warrenty '
        'of any kind, express or implied. Maid is not affiliated with Huggingface, '
        'Meta (Facebook), MistralAi, OpenAI, Google, Microsoft or any other company '
        'providing a model compatible with this application.',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 20.0),
      Text(
        'Lead Maintainer',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Text(
        'Dane Madsen',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    ]
  );
}