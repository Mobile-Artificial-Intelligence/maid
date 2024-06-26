import 'package:flutter/material.dart';
import 'package:maid/ui/mobile/layout/model_settings_app_bar.dart';
import 'package:maid/ui/mobile/parameter_widgets/min_p_parameter.dart';
import 'package:maid/ui/mobile/parameter_widgets/n_predict_parameter.dart';
import 'package:maid/ui/mobile/parameter_widgets/penalize_nl_parameter.dart';
import 'package:maid/ui/mobile/parameter_widgets/mirostat_eta_parameter.dart';
import 'package:maid/ui/mobile/parameter_widgets/mirostat_parameter.dart';
import 'package:maid/ui/mobile/parameter_widgets/mirostat_tau_parameter.dart';
import 'package:maid/ui/mobile/parameter_widgets/n_batch_parameter.dart';
import 'package:maid/ui/mobile/parameter_widgets/n_ctx_parameter.dart';
import 'package:maid/ui/mobile/parameter_widgets/n_threads_parameter.dart';
import 'package:maid/ui/mobile/parameter_widgets/frequency_penalty_parameter.dart';
import 'package:maid/ui/mobile/parameter_widgets/last_n_penalty_parameter.dart';
import 'package:maid/ui/mobile/parameter_widgets/present_penalty_parameter.dart';
import 'package:maid/ui/mobile/parameter_widgets/repeat_penalty_parameter.dart';
import 'package:maid/ui/mobile/parameter_widgets/seed_parameter.dart';
import 'package:maid/ui/mobile/parameter_widgets/temperature_parameter.dart';
import 'package:maid/ui/mobile/parameter_widgets/template_parameter.dart';
import 'package:maid/ui/mobile/parameter_widgets/tfs_z_parameter.dart';
import 'package:maid/ui/mobile/parameter_widgets/top_k_parameter.dart';
import 'package:maid/ui/mobile/parameter_widgets/top_p_parameter.dart';
import 'package:maid/ui/mobile/parameter_widgets/typical_p_parameter.dart';
import 'package:maid/ui/shared/groups/llama_cpp_model_controls.dart';
import 'package:maid/ui/shared/utilities/session_busy_overlay.dart';

class LlamaCppPage extends StatelessWidget {
  const LlamaCppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ModelSettingsAppBar(title: "LlamaCPP Parameters"),
      body: SessionBusyOverlay(
        child: buildListView(context),
      )
    );
  }

  Widget buildListView(BuildContext context) {
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8), 
          child: LlamaCppModelControls()
        ),
        Divider(
          height: 20,
          indent: 10,
          endIndent: 10,
          color: Theme.of(context).colorScheme.primary,
        ),
        const TemplateParameter(),
        Divider(
          height: 20,
          indent: 10,
          endIndent: 10,
          color: Theme.of(context).colorScheme.primary,
        ),
        const PenalizeNlParameter(),
        const SeedParameter(),
        const TemperatureParameter(),
        const TopKParameter(),
        const TopPParameter(),
        const MinPParameter(),
        const TfsZParameter(),
        const TypicalPParameter(),
        const LastNPenaltyParameter(),
        const RepeatPenaltyParameter(),
        const FrequencyPenaltyParameter(),
        const PresentPenaltyParameter(),
        const MirostatParameter(),
        const MirostatTauParameter(),
        const MirostatEtaParameter(),
        const NCtxParameter(),
        const NPredictParameter(),
        const NBatchParameter(),
        const NThreadsParameter(),
      ]
    );
  }
}

 
