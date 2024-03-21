import 'package:flutter/material.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:maid/ui/mobile/widgets/appbars/generic_app_bar.dart';
import 'package:maid/ui/mobile/widgets/dialogs.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/penalize_nl_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/mirostat_eta_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/mirostat_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/mirostat_tau_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/n_batch_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/n_ctx_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/n_threads_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/penalty_frequency_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/penalty_last_n_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/penalty_present_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/penalty_repeat_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/seed_parameter.dart';
import 'package:maid/ui/mobile/widgets/dropdowns/format_dropdown.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/temperature_parameter.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const GenericAppBar(title: "LlamaCPP Parameters"),
        body: Consumer<Session>(
          builder: (context, session, child) {
          return SessionBusyOverlay(
            child: ListView(
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
                          context.watch<AiPlatform>().model,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: () {
                        storageOperationDialog(
                            context, context.read<AiPlatform>().loadModelFile);
                      },
                      child: Text(
                        "Load GGUF",
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    FilledButton(
                      onPressed: () {
                        context.read<AiPlatform>().model = "";
                      },
                      child: Text(
                        "Unload GGUF",
                        style: Theme.of(context).textTheme.labelLarge,
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
                const FormatDropdown(),
                const PenalizeNlParameter(),
                const SeedParameter(),
                const TemperatureParameter(),
                const TopKParameter(),
                const TopPParameter(),
                const TfsZParameter(),
                const TypicalPParameter(),
                const PenaltyLastNParameter(),
                const PenaltyRepeatParameter(),
                const PenaltyFrequencyParameter(),
                const PenaltyPresentParameter(),
                const MirostatParameter(),
                const MirostatTauParameter(),
                const MirostatEtaParameter(),
                const NCtxParameter(),
                const NBatchParameter(),
                const NThreadsParameter(),
              ]
            )
          );
        }
      )
    );
  }
}
