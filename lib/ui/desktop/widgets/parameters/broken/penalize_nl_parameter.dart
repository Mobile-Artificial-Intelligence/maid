import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/ui/shared/widgets/tiles/switch_container.dart';
import 'package:provider/provider.dart';

class PenalizeNlParameter extends StatelessWidget {
  const PenalizeNlParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        final session = appData.currentSession;
        
        return SwitchContainer(
          title: 'Penalize New Line',
          initialValue: session.model.penalizeNewline,
          onChanged: (value) {
            session.model.penalizeNewline = value;
            session.notify();
          },
        );
      }
    );
  }
}
