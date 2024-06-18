import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/ui/shared/widgets/appbars/generic_app_bar.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/api_key_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/n_predict_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/frequency_penalty_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/present_penalty_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/seed_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/temperature_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/top_p_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/url_parameter.dart';
import 'package:maid/ui/shared/widgets/session_busy_overlay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OpenAiPage extends StatelessWidget {
  const OpenAiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GenericAppBar(title: "OpenAI Parameters"),
      body: SessionBusyOverlay(
        child: Consumer<AppData>(
          builder: (context, appData, child) {
            final session = appData.currentSession;
            
            SharedPreferences.getInstance().then((prefs) {
              prefs.setString("open_ai_model", json.encode(session.model.toMap()));
            });

            return ListView(
              children: [
                Align(
                  alignment: Alignment.center, // Center the button horizontally
                  child: FilledButton(
                    onPressed: () {
                      session.model.reset();
                    },
                    child: Text(
                      "Reset",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                const ApiKeyParameter(),
                Divider(
                  height: 20,
                  indent: 10,
                  endIndent: 10,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const UrlParameter(),
                const SizedBox(height: 20.0),
                const SeedParameter(),
                const TemperatureParameter(),
                const FrequencyPenaltyParameter(),
                const PresentPenaltyParameter(),
                const NPredictParameter(),
                const TopPParameter()
              ]
            );
          },
        ),
      )
    );
  }
}
