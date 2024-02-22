import 'package:flutter/material.dart';
import 'package:maid/widgets/parameter_widgets/api_key_parameter.dart';
import 'package:maid/widgets/parameter_widgets/penalize_nl_parameter.dart';
import 'package:maid/widgets/parameter_widgets/mirostat_eta_parameter.dart';
import 'package:maid/widgets/parameter_widgets/mirostat_parameter.dart';
import 'package:maid/widgets/parameter_widgets/mirostat_tau_parameter.dart';
import 'package:maid/widgets/parameter_widgets/n_batch_parameter.dart';
import 'package:maid/widgets/parameter_widgets/n_ctx_parameter.dart';
import 'package:maid/widgets/parameter_widgets/n_keep_parameter.dart';
import 'package:maid/widgets/parameter_widgets/n_predict_parameter.dart';
import 'package:maid/widgets/parameter_widgets/n_threads_parameter.dart';
import 'package:maid/widgets/parameter_widgets/penalty_frequency_parameter.dart';
import 'package:maid/widgets/parameter_widgets/penalty_last_n_parameter.dart';
import 'package:maid/widgets/parameter_widgets/penalty_present_parameter.dart';
import 'package:maid/widgets/parameter_widgets/penalty_repeat_parameter.dart';
import 'package:maid/widgets/parameter_widgets/seed_parameter.dart';
import 'package:maid/widgets/parameter_widgets/temperature_parameter.dart';
import 'package:maid/widgets/parameter_widgets/tfs_z_parameter.dart';
import 'package:maid/widgets/parameter_widgets/top_k_parameter.dart';
import 'package:maid/widgets/parameter_widgets/top_p_parameter.dart';
import 'package:maid/widgets/parameter_widgets/typical_p_parameter.dart';
import 'package:maid/widgets/dropdowns/model_dropdown.dart';
import 'package:maid/widgets/parameter_widgets/url_parameter.dart';

class OllamaPlatform extends StatelessWidget {
  const OllamaPlatform({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const ApiKeyParameter(),
      Divider(
        height: 20,
        indent: 10,
        endIndent: 10,
        color: Theme.of(context).colorScheme.primary,
      ),
      const UrlParameter(),
      const SizedBox(height: 8.0),
      const ModelDropdown(),
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
    ]);
  }
}
