import 'package:flutter/material.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/ui/mobile/widgets/appbars/generic_app_bar.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/api_key_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/n_predict_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/penalty_frequency_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/penalty_present_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/seed_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/temperature_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/top_p_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/url_parameter.dart';
import 'package:provider/provider.dart';

class OpenAiPage extends StatefulWidget {
  const OpenAiPage({super.key});

  @override
  State<OpenAiPage> createState() => _OpenAiPageState();
}

class _OpenAiPageState extends State<OpenAiPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const GenericAppBar(title: "OpenAI Parameters"),
        body: Consumer<Session>(builder: (context, session, child) {
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
                const SizedBox(height: 20.0),
                const SeedParameter(),
                const TemperatureParameter(),
                const PenaltyFrequencyParameter(),
                const PenaltyPresentParameter(),
                const NPredictParameter(),
                const TopPParameter()
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
