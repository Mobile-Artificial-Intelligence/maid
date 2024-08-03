import 'package:flutter/material.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:provider/provider.dart';

class SeedParameter extends StatelessWidget {
  const SeedParameter({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController(
      text: LargeLanguageModel.of(context).seed.toString()
    );

    return Selector<AppData, bool>(
      selector: (context, appData) => appData.model.randomSeed,
      builder: (context, randomSeed, child) => buildColumn(context, randomSeed, controller),
    );
  }

  Widget buildColumn(BuildContext context, bool randomSeed, TextEditingController controller) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Random Seed'),
          value: randomSeed,
          onChanged: (value) {
            LargeLanguageModel.of(context).randomSeed = value;
          },
        ),
        Divider(
          height: 20,
          indent: 10,
          endIndent: 10,
          color: Theme.of(context).colorScheme.primary,
        ),
        if (!randomSeed)
          ListTile(
            title: Row(
              children: [
                const Expanded(
                  child: Text('seed'),
                ),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'seed',
                    ),
                    onChanged: (value) {
                      LargeLanguageModel.of(context).seed = int.parse(value);
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
