import 'package:flutter/material.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/classes/providers/large_language_models/llama_cpp_model.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:maid/ui/desktop/parameters/api_key_parameter.dart';
import 'package:maid/ui/desktop/parameters/n_keep_parameter.dart';
import 'package:maid/ui/desktop/parameters/penalize_nl_parameter.dart';
import 'package:maid/ui/desktop/parameters/frequency_penalty_parameter.dart';
import 'package:maid/ui/desktop/parameters/last_n_penalty_parameter.dart';
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
import 'package:maid/ui/desktop/parameters/url_parameter.dart';
import 'package:maid/ui/desktop/parameters/use_default.dart';
import 'package:maid/ui/shared/layout/dialogs.dart';
import 'package:maid/ui/shared/utilities/session_busy_overlay.dart';
import 'package:provider/provider.dart';

class OllamaPanel extends StatelessWidget {
  const OllamaPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Ollama Parameters",
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
              alignment: Alignment.center, // Center the button horizontally
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
            buildTextWrap(),
            buildDivider(context),
            buildSwitchWrap(),
            buildDivider(context),
            Consumer<AppData>(
              builder: buildGridView
            )
          ]
        ),
      )
    );
  }

  Widget buildTextWrap() {
    return const Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        UrlParameter(),
        ApiKeyParameter(),
      ],
    );
  }

  Widget buildSwitchWrap() {
    return const Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        PenalizeNlParameter(),
        UseDefaultParameter(),
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

  Widget buildGridView(BuildContext context, AppData appData, Widget? child) {
    final model = appData.currentSession.model;

    return GridView(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 1.25
      ),
      shrinkWrap: true,
      children: [
        const SeedParameter(),
        if (!model.useDefault) ...[
          const NThreadsParameter(),
          const NCtxParameter(),
          const NBatchParameter(),
          const NPredictParameter(),
          const NKeepParameter(),
          const TopKParameter(),
          const TopPParameter(),
          const TfsZParameter(),
          const TypicalPParameter(),
          const TemperatureParameter(),
          const LastNPenaltyParameter(),
          const RepeatPenaltyParameter(),
          const FrequencyPenaltyParameter(),
          const PresentPenaltyParameter(),
          const MirostatParameter(),
          const MirostatTauParameter(),
          const MirostatEtaParameter()
        ]
      ],
    );
  }
}

 
