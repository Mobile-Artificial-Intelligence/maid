import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {
          Navigator.of(context).pop();
        },),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
          ),
        ),
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 0.0),
        child: Column(
          children: [
            Image.asset(
              "assets/maid.png",
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 30.0),
            Center(
              child: Text(
                'Maid',
                style: Theme.of(context).textTheme.titleLarge,
              )
            ),
            const SizedBox(height: 20.0),
            Linkify(
              onOpen: _onOpen,
              text: 'Maid is a cross-platform open source app for interacting with GGUF Large Language Models. '
              'This app is distributed under the MIT License. The source code of this project can be found '
              'on github ( https://github.com/MaidFoundation/Maid ). This app was originally forked off sherpa which '
              'can also be found on github ( https://github.com/Bip-Rep/sherpa ). Maid is not affiliated with Meta, '
              'OpenAI or any other company that provides a model which can be used with this app. Model files are '
              'not included with this app and must be downloaded separately. Model files can be downloaded online '
              'at https://huggingface.co',
              style: Theme.of(context).textTheme.bodyMedium
            )
          ]
        ),
      ),
    );
  }

  Future<void> _onOpen(LinkableElement link) async {
    if (!await launchUrl(Uri.parse(link.url))) {
      throw Exception('Could not launch ${link.url}');
    }
  }
}
