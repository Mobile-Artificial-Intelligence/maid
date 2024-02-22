import 'package:flutter/material.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:provider/provider.dart';

class SeedParameter extends StatelessWidget {
  const SeedParameter({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController(
        text: context.read<AiPlatform>().parameters["seed"]?.toString() ?? "");

    return Consumer<AiPlatform>(builder: (context, ai, child) {
      return Column(
        children: [
          SwitchListTile(
            title: const Text('random_seed'),
            value: ai.parameters["random_seed"] ?? true,
            onChanged: (value) {
              ai.setParameter("random_seed", value);
            },
          ),
          Divider(
            height: 20,
            indent: 10,
            endIndent: 10,
            color: Theme.of(context).colorScheme.primary,
          ),
          if (!(ai.parameters["random_seed"] ?? true))
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
                        ai.setParameter("seed", int.parse(value));
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
