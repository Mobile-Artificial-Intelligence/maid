import 'package:flutter/material.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/ui/desktop/parameters/api_key_parameter.dart';
import 'package:maid/ui/desktop/parameters/frequency_penalty_parameter.dart';
import 'package:maid/ui/desktop/parameters/n_predict_parameter.dart';
import 'package:maid/ui/desktop/parameters/present_penalty_parameter.dart';
import 'package:maid/ui/desktop/parameters/seed_parameter.dart';
import 'package:maid/ui/desktop/parameters/temperature_parameter.dart';
import 'package:maid/ui/desktop/parameters/top_p_parameter.dart';
import 'package:maid/ui/desktop/parameters/url_parameter.dart';
import 'package:maid/ui/shared/utilities/session_busy_overlay.dart';

class OpenAiPanel extends StatelessWidget {
  const OpenAiPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "OpenAI Parameters",
          maxLines: 2,
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: SessionBusyOverlay(
        child: ListView(
          padding: const EdgeInsets.all(8.0),
          children: [
            Align(
              alignment: Alignment.center,
              child: FilledButton(
                onPressed: () {
                  LargeLanguageModel.of(context).reset();
                },
                child: Text(
                  "Reset",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
            buildDivider(context),
            buildWrap(),
            buildDivider(context),
            buildGridView(context),
          ]
        ),
      )
    );
  }

  Widget buildDivider(BuildContext context) {
    return Divider(
      height: 20,
      indent: 10,
      endIndent: 10,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  Widget buildWrap() {
    return const Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        UrlParameter(),
        ApiKeyParameter()
      ],
    );
  }

  Widget buildGridView(BuildContext context) {
    return GridView(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 1.25
      ),
      shrinkWrap: true,
      children: const [
        SeedParameter(),
        TemperatureParameter(),
        FrequencyPenaltyParameter(),
        PresentPenaltyParameter(),
        NPredictParameter(),
        TopPParameter()
      ],
    );
  }
}

 
