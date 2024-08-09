import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/classes/providers/artificial_intelligence.dart';
import 'package:maid/ui/mobile/layout/model_settings_app_bar.dart';
import 'package:maid/ui/mobile/parameter_widgets/api_key_parameter.dart';
import 'package:maid/ui/mobile/parameter_widgets/seed_parameter.dart';
import 'package:maid/ui/mobile/parameter_widgets/temperature_parameter.dart';
import 'package:maid/ui/mobile/parameter_widgets/top_p_parameter.dart';
import 'package:maid/ui/mobile/parameter_widgets/url_parameter.dart';
import 'package:maid/ui/shared/utilities/session_busy_overlay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MistralAiPage extends StatelessWidget {
  const MistralAiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ModelSettingsAppBar(title: "MistralAI Parameters"),
      body: SessionBusyOverlay(
        child: Consumer<ArtificialIntelligence>(
          builder: listViewBuilder,
        ),
      )
    );
  }

  Widget listViewBuilder(BuildContext context, ArtificialIntelligence ai, Widget? child) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("mistral_ai_model", json.encode(ai.llm.toMap()));
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
        const TopPParameter(),
        const TemperatureParameter(),
      ]
    );
  }
}
