import 'package:flutter/material.dart';
import 'package:maid/classes/large_language_model.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/providers/session.dart';
import 'package:provider/provider.dart';

class SeedParameter extends StatelessWidget {
  const SeedParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.3,
      ),
      child: buildColumn(context),
    );
  }

  Widget buildColumn(BuildContext context) {
    return Column(
      children: [
        const Text('Random Seed'),
        const SizedBox(height: 5.0),
        buildRow(context)
      ],
    );
  }

  Widget buildRow(BuildContext context) {
    TextEditingController controller = TextEditingController(
      text: LargeLanguageModel.of(context).seed.toString()
    );

    return Row(
      children: [
        buildSwitch(),
        const SizedBox(width: 5.0),
        Expanded( // Added Expanded widget here
          child: TextField(
            keyboardType: TextInputType.number,
            cursorColor: Theme.of(context).colorScheme.secondary,
            textAlign: TextAlign.center,
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'seed',
            ),
            onChanged: (value) {
              LargeLanguageModel.of(context).seed = int.parse(value);
              Session.of(context).notify();
            },
          ),
        ),
      ]
    );
  }

  Widget buildSwitch() {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        final session = appData.currentSession;
        
        return Switch(
          value: session.model.randomSeed,
          onChanged: (value) {
            session.model.randomSeed = value;
            session.notify();
          },
        );
      }
    );
  }
}
