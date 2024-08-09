import 'package:flutter/material.dart';
import 'package:maid/classes/providers/artificial_intelligence.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/ui/shared/tiles/switch_container.dart';
import 'package:provider/provider.dart';

class PenalizeNlParameter extends StatelessWidget {
  const PenalizeNlParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ArtificialIntelligence>(
      builder: buildSwitchContainer
    );
  }

  Widget buildSwitchContainer(BuildContext context, ArtificialIntelligence ai, Widget? child) {
    return SwitchContainer(
      title: 'Penalize New Line',
      initialValue: ai.llm.penalizeNewline,
      onChanged: (value) {
        LargeLanguageModel.of(context).penalizeNewline = value;
      },
    );
  }
}
