import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_data.dart';
import 'package:maid/ui/mobile/layout/model_settings_app_bar.dart';
import 'package:maid/ui/mobile/parameter_widgets/api_key_parameter.dart';
import 'package:maid/ui/mobile/parameter_widgets/n_keep_parameter.dart';
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
import 'package:maid/ui/mobile/parameter_widgets/tfs_z_parameter.dart';
import 'package:maid/ui/mobile/parameter_widgets/top_k_parameter.dart';
import 'package:maid/ui/mobile/parameter_widgets/top_p_parameter.dart';
import 'package:maid/ui/mobile/parameter_widgets/typical_p_parameter.dart';
import 'package:maid/ui/mobile/parameter_widgets/url_parameter.dart';
import 'package:maid/ui/mobile/parameter_widgets/use_default.dart';
import 'package:maid/ui/shared/utilities/session_busy_overlay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OllamaPage extends StatelessWidget {
  const OllamaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ModelSettingsAppBar(title: "Ollama Parameters"),
      body: SessionBusyOverlay(
        child: Consumer<AppData>(
          builder: listViewBuilder
        )
      )
    );
  }

  Widget listViewBuilder(BuildContext context, AppData appData, Widget? child) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("ollama_model", json.encode(appData.model.toMap()));
    });

    return ListView(
      children: [
        const ApiKeyParameter(),
        Divider(
          height: 20,
          indent: 10,
          endIndent: 10,
          color: Theme.of(context).colorScheme.primary,
        ),
        const UrlParameter(),
        const SizedBox(height: 8.0),
        const SeedParameter(),
        const UseDefaultParameter(),
        if (!appData.model.useDefault) ...[
          const SizedBox(height: 20.0),
          Divider(
            height: 20,
            indent: 10,
            endIndent: 10,
            color: Theme.of(context).colorScheme.primary,
          ),
          const PenalizeNlParameter(),
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
      ]
    );
  }
}
