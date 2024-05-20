import 'package:flutter/material.dart';
import 'package:maid/providers/session.dart';
import 'package:provider/provider.dart';

class SeedParameter extends StatelessWidget {
  const SeedParameter({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController controller =
        TextEditingController(text: context.read<Session>().model.seed.toString());

    return Consumer<Session>(
      builder: (context, session, child) {
        return Column(
          children: [
            SwitchListTile(
              title: const Text('Random Seed'),
              value: session.model.randomSeed,
              onChanged: (value) {
                session.model.randomSeed = value;
                session.notify();
              },
            ),
            Divider(
              height: 20,
              indent: 10,
              endIndent: 10,
              color: Theme.of(context).colorScheme.primary,
            ),
            if (!session.model.randomSeed)
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
                          session.model.seed = int.parse(value);
                          session.notify();
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      }
    );
  }
}
