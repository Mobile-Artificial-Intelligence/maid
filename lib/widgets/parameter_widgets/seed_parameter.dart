import 'package:flutter/material.dart';
import 'package:maid/providers/model.dart';
import 'package:provider/provider.dart';

class SeedParameter extends StatelessWidget {
  const SeedParameter({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController(
        text: context.read<AiPlatform>().parameters["seed"]?.toString() ?? "");

    return Consumer<AiPlatform>(builder: (context, model, child) {
      return Column(
        children: [
          SwitchListTile(
            title: const Text('random_seed'),
            value: model.parameters["random_seed"] ?? true,
            onChanged: (value) {
              model.setParameter("random_seed", value);
            },
          ),
          Divider(
            height: 20,
            indent: 10,
            endIndent: 10,
            color: Theme.of(context).colorScheme.primary,
          ),
          if (!(model.parameters["random_seed"] ?? true))
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
                        model.setParameter("seed", int.parse(value));
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }
}
