import 'package:flutter/material.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/api_key_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/n_keep_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/n_predict_parameter.dart';
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
import 'package:maid/ui/mobile/widgets/parameter_widgets/temperature_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/tfs_z_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/top_k_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/top_p_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/typical_p_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/url_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/use_default.dart';
import 'package:provider/provider.dart';

class OllamaPage extends StatefulWidget {
  const OllamaPage({super.key});

  @override
  State<OllamaPage> createState() => _OllamaPageState();
}

class _OllamaPageState extends State<OllamaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
            ),
          ),
          title: const Text("Model"),
        ),
        body: Consumer2<Session, AiPlatform>(
            builder: (context, session, ai, child) {
          return Stack(
            children: [
              ListView(children: [
                const ApiKeyParameter(),
                Divider(
                  height: 20,
                  indent: 10,
                  endIndent: 10,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const UrlParameter(),
                const SizedBox(height: 8.0),
                const UseDefaultParameter(),
                if (ai.useDefault) ...[
                  const SizedBox(height: 20.0),
                  Divider(
                    height: 20,
                    indent: 10,
                    endIndent: 10,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const PenalizeNlParameter(),
                  const SeedParameter(),
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
                  const PenaltyLastNParameter(),
                  const PenaltyRepeatParameter(),
                  const PenaltyFrequencyParameter(),
                  const PenaltyPresentParameter(),
                  const MirostatParameter(),
                  const MirostatTauParameter(),
                  const MirostatEtaParameter()
                ]
              ]),
              if (session.isBusy)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.4),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          );
        }));
  }
}
