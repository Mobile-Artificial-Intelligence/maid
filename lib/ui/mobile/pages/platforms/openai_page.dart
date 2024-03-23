import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:maid/ui/mobile/widgets/appbars/generic_app_bar.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/api_key_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/n_predict_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/penalty_frequency_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/penalty_present_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/seed_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/temperature_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/top_p_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/url_parameter.dart';
import 'package:maid/ui/mobile/widgets/session_busy_overlay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OpenAiPage extends StatelessWidget {
  const OpenAiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GenericAppBar(title: "OpenAI Parameters"),
      body: SessionBusyOverlay(
        child: Consumer<AiPlatform>(
          builder: (context, ai, child) {
            SharedPreferences.getInstance().then((prefs) {
              prefs.setString("open_ai_model", json.encode(ai.toMap()));
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
                const SizedBox(height: 20.0),
                const SeedParameter(),
                const TemperatureParameter(),
                const PenaltyFrequencyParameter(),
                const PenaltyPresentParameter(),
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
