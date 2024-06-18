import 'package:flutter/material.dart';
import 'package:maid/classes/large_language_model.dart';
import 'package:maid/classes/llama_cpp_model.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/ui/desktop/widgets/parameters/penalize_nl_parameter.dart';
import 'package:maid/ui/desktop/widgets/parameters/template_parameter.dart';
import 'package:maid/ui/desktop/widgets/parameters/frequency_penalty_parameter.dart';
import 'package:maid/ui/desktop/widgets/parameters/last_n_penalty_parameter.dart';
import 'package:maid/ui/desktop/widgets/parameters/min_p_parameter.dart';
import 'package:maid/ui/desktop/widgets/parameters/mirostat_eta_parameter.dart';
import 'package:maid/ui/desktop/widgets/parameters/mirostat_parameter.dart';
import 'package:maid/ui/desktop/widgets/parameters/mirostat_tau_parameter.dart';
import 'package:maid/ui/desktop/widgets/parameters/n_batch_parameter.dart';
import 'package:maid/ui/desktop/widgets/parameters/n_ctx_parameter.dart';
import 'package:maid/ui/desktop/widgets/parameters/n_predict_parameter.dart';
import 'package:maid/ui/desktop/widgets/parameters/n_threads_parameter.dart';
import 'package:maid/ui/desktop/widgets/parameters/present_penalty_parameter.dart';
import 'package:maid/ui/desktop/widgets/parameters/repeat_penalty_parameter.dart';
import 'package:maid/ui/desktop/widgets/parameters/temperature_parameter.dart';
import 'package:maid/ui/desktop/widgets/parameters/tfs_z_parameter.dart';
import 'package:maid/ui/desktop/widgets/parameters/top_k_parameter.dart';
import 'package:maid/ui/desktop/widgets/parameters/top_p_parameter.dart';
import 'package:maid/ui/desktop/widgets/parameters/typical_p_parameter.dart';
import 'package:maid/ui/shared/widgets/dialogs.dart';
import 'package:maid/ui/mobile/widgets/session_busy_overlay.dart';
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
            buildModelName(),
            const SizedBox(height: 10.0),
            buildButtons(context),
            buildDivider(context),
            buildSpecial(),
            buildDivider(context),
            buildGridView(context),
          ]
        ),
      )
    );
  }

  Widget buildSpecial() {
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

  Widget buildButtons(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 6,
      children: [
        FilledButton(
          onPressed: () {
            LargeLanguageModel.of(context).reset();
          },
          child: const Text(
            "Reset"
          ),
        ),
        FilledButton(
          onPressed: () {
            storageOperationDialog(
              context, 
              LlamaCppModel.of(context).loadModel
            );
          },
          child: const Text(
            "Load GGUF"
          ),
        ),
        FilledButton(
          onPressed: () {
            LargeLanguageModel.of(context).resetUri();
          },
          child: const Text(
            "Unload GGUF"
          ),
        ),
      ],
    );
  }

  Widget buildModelName() {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        final session = appData.currentSession;

        if (session.model.name.isEmpty) {
          return const SizedBox.shrink();
        }

        return Text(
          "Model: ${session.model.name}",
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
        //SeedParameter(),
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

 
