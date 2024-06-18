import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/ui/shared/widgets/tiles/switch_container.dart';
import 'package:provider/provider.dart';

class UseDefaultParameter extends StatelessWidget {
  const UseDefaultParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        final session = appData.currentSession;
        
        return SwitchContainer(
          title: 'Use Default Parameters',
          initialValue: session.model.useDefault,
          onChanged: (value) {
            session.model.useDefault = value;
            session.notify();
          },
        );
      }
    );
  }
}
