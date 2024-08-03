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
        child: Selector<AppData, LargeLanguageModel>(
          selector: (context, appData) => appData.model,
          builder: buildColumn
        ),
      )
    );
  }

  Widget buildColumn(BuildContext context, LargeLanguageModel model, Widget? child) {

    TextEditingController controller = TextEditingController(
      text: LargeLanguageModel.of(context).seed.toString()
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Random Seed'),
        Flexible(
          child: Switch(
            value: model.randomSeed,
            onChanged: (value) {
              model.randomSeed = value;
            },
          )
        ),
        Flexible(
          child: TextField(
            enabled: !model.randomSeed,
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
