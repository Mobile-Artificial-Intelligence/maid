import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:provider/provider.dart';

class UseDefaultParameter extends StatelessWidget {
  const UseDefaultParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        final session = appData.currentSession;
        
        return SwitchListTile(
          title: const Text('Use Default Parameters'),
          value: session.model.useDefault,
          onChanged: (value) {
            session.model.useDefault = value;
            session.notify();
          },
        );
      }
    );
  }
}
