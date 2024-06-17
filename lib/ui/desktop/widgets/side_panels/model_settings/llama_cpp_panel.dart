import 'package:flutter/material.dart';
import 'package:maid/classes/llama_cpp_model.dart';
import 'package:maid/providers/app_data.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/ui/shared/widgets/dialogs.dart';
import 'package:maid/ui/mobile/widgets/session_busy_overlay.dart';
import 'package:provider/provider.dart';

class LlamaCppPanel extends StatefulWidget {
  const LlamaCppPanel({super.key});

  @override
  State<LlamaCppPanel> createState() => _LlamaCppPanelState();
}

class _LlamaCppPanelState extends State<LlamaCppPanel> {
  late Session session;

  @override
  void dispose() {
    (session.model as LlamaCppModel).init();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "LlamaCPP Parameters"
        ),
        centerTitle: true,
      ),
      body: SessionBusyOverlay(
        child: Consumer<AppData>(
          builder: (context, appData, child) {
            session = appData.currentSession;

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
              children: [
                if (session.model.uri.isNotEmpty)
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    const Text("Model Path"),
                    Text(
                      session.model.uri,
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
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
                GridView(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 250,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 1.25
                  ),
                  shrinkWrap: true,
                  children: [
                    GridTile(
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceDim,
                          borderRadius: BorderRadius.circular(8.0)
                        ),
                        child: Column(
                          children: [
                            const Text("Slider Test"),
                            Flexible(
                              child: Slider(
                                value: 50,
                                min: 0,
                                max: 100,
                                divisions: 100,
                                onChanged: (value) {},
                              ),
                            ),
                            const Flexible(
                              child: TextField(),
                            )
                          ],
                        )
                      ),
                    ),
                    GridTile(
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceDim,
                          borderRadius: BorderRadius.circular(8.0)
                        ),
                        child: Column(
                          children: [
                            const Text("Slider Test"),
                            Flexible(
                              child: Slider(
                                value: 50,
                                min: 0,
                                max: 100,
                                divisions: 100,
                                onChanged: (value) {},
                              ),
                            ),
                            const Flexible(
                              child: TextField(),
                            )
                          ],
                        )
                      ),
                    ),
                    GridTile(
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceDim,
                          borderRadius: BorderRadius.circular(8.0)
                        ),
                        child: Column(
                          children: [
                            const Text("Slider Test"),
                            Flexible(
                              child: Slider(
                                value: 50,
                                min: 0,
                                max: 100,
                                divisions: 100,
                                onChanged: (value) {},
                              ),
                            ),
                            const Flexible(
                              child: TextField(),
                            )
                          ],
                        )
                      ),
                    ),
                  ],
                )
              ]
            )
            );
          },
        ),
      )
    );
  }
}

 
