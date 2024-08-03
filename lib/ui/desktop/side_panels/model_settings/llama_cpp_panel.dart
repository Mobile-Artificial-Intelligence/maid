import 'package:flutter/material.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:maid/ui/desktop/parameters/penalize_nl_parameter.dart';
import 'package:maid/ui/desktop/parameters/template_parameter.dart';
import 'package:maid/ui/desktop/parameters/frequency_penalty_parameter.dart';
import 'package:maid/ui/desktop/parameters/last_n_penalty_parameter.dart';
import 'package:maid/ui/desktop/parameters/min_p_parameter.dart';
import 'package:maid/ui/desktop/parameters/mirostat_eta_parameter.dart';
import 'package:maid/ui/desktop/parameters/mirostat_parameter.dart';
import 'package:maid/ui/desktop/parameters/mirostat_tau_parameter.dart';
import 'package:maid/ui/desktop/parameters/n_batch_parameter.dart';
import 'package:maid/ui/desktop/parameters/n_ctx_parameter.dart';
import 'package:maid/ui/desktop/parameters/n_predict_parameter.dart';
import 'package:maid/ui/desktop/parameters/n_threads_parameter.dart';
import 'package:maid/ui/desktop/parameters/present_penalty_parameter.dart';
import 'package:maid/ui/desktop/parameters/repeat_penalty_parameter.dart';
import 'package:maid/ui/desktop/parameters/temperature_parameter.dart';
import 'package:maid/ui/desktop/parameters/tfs_z_parameter.dart';
import 'package:maid/ui/desktop/parameters/top_k_parameter.dart';
import 'package:maid/ui/desktop/parameters/top_p_parameter.dart';
import 'package:maid/ui/desktop/parameters/typical_p_parameter.dart';
import 'package:maid/ui/desktop/parameters/seed_parameter.dart';
import 'package:maid/ui/shared/utilities/session_busy_overlay.dart';
import 'package:provider/provider.dart';

class LlamaCppPanel extends StatelessWidget {
  const LlamaCppPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "LlamaCPP Parameters",
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

  Widget buildWrap() {
    return const Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        TemplateParameter(),
        PenalizeNlParameter(),
      ],
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

  Widget buildModelName() {
    return Selector<AppData, String>(
      selector: (context, appData) => appData.model.name,
      builder: (context, modelName, child) {
        if (modelName.isEmpty) {
          return const SizedBox.shrink();
        }

        return Text(
          "Model: $modelName",
          textAlign: TextAlign.center,
        );
      }
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
        TopKParameter(),
        TopPParameter(),
        MinPParameter(),
        TfsZParameter(),
        TypicalPParameter(),
        LastNPenaltyParameter(),
        RepeatPenaltyParameter(),
        FrequencyPenaltyParameter(),
        PresentPenaltyParameter(),
        MirostatParameter(),
        MirostatTauParameter(),
        MirostatEtaParameter(),
        NCtxParameter(),
        NPredictParameter(),
        NBatchParameter(),
        NThreadsParameter(),
      ],
    );
  }
}

 
