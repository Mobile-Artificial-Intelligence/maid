import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/ui/shared/tiles/switch_container.dart';
import 'package:provider/provider.dart';

class PenalizeNlParameter extends StatelessWidget {
  const PenalizeNlParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AppData, bool>(
      selector: (context, appData) => appData.model.penalizeNewline,
      builder: buildSwitchContainer
    );
  }

  Widget buildSwitchContainer(BuildContext context, bool penalizeNewline, Widget? child) {
    return SwitchContainer(
      title: 'Penalize New Line',
      initialValue: penalizeNewline,
      onChanged: (value) {
        LargeLanguageModel.of(context).penalizeNewline = value;
      },
    );
  }
}
