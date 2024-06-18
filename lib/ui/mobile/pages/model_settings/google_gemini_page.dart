import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/classes/large_language_model.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/ui/shared/widgets/appbars/generic_app_bar.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/api_key_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/n_predict_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/temperature_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/top_k_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/top_p_parameter.dart';
import 'package:maid/ui/shared/widgets/session_busy_overlay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleGeminiPage extends StatelessWidget {
  const GoogleGeminiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GenericAppBar(title: "Google Gemini Parameters"),
      body: SessionBusyOverlay(
        child: Consumer<AppData>(
          builder: (context, appData, child) {
            final session = appData.currentSession;

            SharedPreferences.getInstance().then((prefs) {
              prefs.setString("google_gemini_model", json.encode(session.model.toMap()));
            });

            return ListView(
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
                const SizedBox(height: 10.0),
                const ApiKeyParameter(),
                Divider(
                  height: 20,
                  indent: 10,
                  endIndent: 10,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 20.0),
                const NPredictParameter(),
                const TopPParameter(),
                const TopKParameter(),
                const TemperatureParameter(),
              ]
            );
          },
        ),
      )
    );
  }
}
