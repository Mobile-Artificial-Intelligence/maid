import 'package:flutter/material.dart';
import 'package:maid/providers/session.dart';
import 'package:provider/provider.dart';

class PenalizeNlParameter extends StatelessWidget {
  const PenalizeNlParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) {
        return SwitchListTile(
          title: const Text('penalize_nl'),
          value: session.model.penalizeNewline,
          onChanged: (value) {
            session.model.penalizeNewline = value;
            session.notify();
          },
        );
      }
    );
  }
}
