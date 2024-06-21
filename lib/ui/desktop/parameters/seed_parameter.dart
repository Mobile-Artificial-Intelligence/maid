import 'package:flutter/material.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:maid/classes/providers/session.dart';
import 'package:provider/provider.dart';

class SeedParameter extends StatelessWidget {
  const SeedParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return GridTile(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceDim,
          borderRadius: BorderRadius.circular(8.0)
        ),
        child: Consumer<AppData>(
          builder: buildColumn
        ),
      )
    );
  }

  Widget buildColumn(BuildContext context, AppData appData, Widget? child) {
    final session = appData.currentSession;

    TextEditingController controller = TextEditingController(
      text: LargeLanguageModel.of(context).seed.toString()
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Random Seed'),
        Flexible(
          child: Switch(
            value: session.model.randomSeed,
            onChanged: (value) {
              session.model.randomSeed = value;
              session.notify();
            },
          )
        ),
        Flexible(
          child: TextField(
            enabled: !session.model.randomSeed,
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
          )
        )
      ],
    );
  }
}
