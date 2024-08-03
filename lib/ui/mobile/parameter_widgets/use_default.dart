import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:provider/provider.dart';

class UseDefaultParameter extends StatelessWidget {
  const UseDefaultParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AppData, bool>(
      selector: (context, appData) => appData.model.useDefault,
      builder: buildSwitchContainer
    );
  }

  Widget buildSwitchContainer(BuildContext context, bool useDefault, Widget? child) {
    return SwitchListTile(
      title: const Text('Use Default Parameters'),
      value: useDefault,
      onChanged: (value) {
        LargeLanguageModel.of(context).useDefault = value;
      },
    );
  }
}
