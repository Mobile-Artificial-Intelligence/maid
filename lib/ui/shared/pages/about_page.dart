import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:maid/ui/shared/layout/generic_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GenericAppBar(title: "About Maid"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 0.0),
        child: Column(
          children: [
            const SizedBox(height: 20.0),
            Image.asset(
              "assets/maid.png",
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
              style: Theme.of(context).textTheme.bodyMedium
            ),
            const SizedBox(height: 20.0),
            Text(
              'Contributors',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20.0),
            Text(
              'Lead Maintainer',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              'Dane Madsen',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20.0),
            Text(
              'Maid Contributors',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              'sfiannaca',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'gardner',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ]
        )
      )
    );
  }

  Future<void> _onOpen(LinkableElement link) async {
    if (!await launchUrl(Uri.parse(link.url))) {
      throw Exception('Could not launch ${link.url}');
    }
  }
}
