import 'package:flutter/material.dart';
import 'package:maid/classes/llama_cpp_model.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/ui/shared/widgets/appbars/generic_app_bar.dart';
import 'package:maid/ui/shared/widgets/dialogs.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/min_p_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/n_predict_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/penalize_nl_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/mirostat_eta_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/mirostat_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/mirostat_tau_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/n_batch_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/n_ctx_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/n_threads_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/frequency_penalty_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/last_n_penalty_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/present_penalty_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/repeat_penalty_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/seed_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/temperature_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/template_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/tfs_z_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/top_k_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/top_p_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/typical_p_parameter.dart';
import 'package:maid/ui/mobile/widgets/session_busy_overlay.dart';
import 'package:provider/provider.dart';

class LlamaCppPage extends StatefulWidget {
  const LlamaCppPage({super.key});

  @override
  State<LlamaCppPage> createState() => _LlamaCppPageState();
}

class _LlamaCppPageState extends State<LlamaCppPage> {
  late Session session;

  @override
  void dispose() {
    (session.model as LlamaCppModel).init();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GenericAppBar(title: "LlamaCPP Parameters"),
      body: SessionBusyOverlay(
        child: Consumer<AppData>(
          builder: (context, appData, child) {
            session = appData.currentSession;

            return ListView(
              children: [
                ListTile(
                  title: Row(
                    children: [
                      const Expanded(
                        child: Text("Model Path"),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          session.model.uri,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15.0),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    FilledButton(
                      onPressed: () {
                        session.model.reset();
                      },
                      child: const Text(
                        "Reset"
                      ),
                    ),
                    FilledButton(
                      onPressed: () {
                        storageOperationDialog(
                          context, 
                          (session.model as LlamaCppModel).loadModel
                        );
                        session.notify();
                      },
                      child: const Text(
                        "Load GGUF"
                      ),
                    ),
                    FilledButton(
                      onPressed: () {
                        session.model.resetUri();
                        session.notify();
                      },
                      child: const Text(
                        "Unload GGUF"
                      ),
                    ),
                  ],
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
          },
        ),
      )
    );
  }
}

 
