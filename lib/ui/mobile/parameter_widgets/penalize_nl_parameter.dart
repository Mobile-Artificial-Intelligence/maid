import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:provider/provider.dart';

class PenalizeNlParameter extends StatelessWidget {
  const PenalizeNlParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        final session = appData.currentSession;
        
        return SwitchListTile(
          title: const Text('Penalize New Line'),
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
