import 'package:flutter/material.dart';
import 'package:maid/providers/session.dart';
import 'package:provider/provider.dart';

class UseDefaultParameter extends StatelessWidget {
  const UseDefaultParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) {
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
