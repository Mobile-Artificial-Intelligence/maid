import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/static/logger.dart';
import 'package:maid/providers/ai_platform.dart';
import 'package:maid/ui/mobile/widgets/platform_widgets/local_platform.dart';
import 'package:maid/ui/mobile/widgets/platform_widgets/mistralai_platform.dart';
import 'package:maid/ui/mobile/widgets/platform_widgets/ollama_platform.dart';
import 'package:maid/ui/mobile/widgets/platform_widgets/openai_platform.dart';
import 'package:maid/ui/mobile/widgets/dialogs.dart';
import 'package:maid/ui/mobile/widgets/dropdowns/api_dropdown.dart';
import 'package:maid/ui/mobile/widgets/double_button_row.dart';
import 'package:maid/ui/mobile/widgets/text_field_list_tile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlatformPage extends StatefulWidget {
  const PlatformPage({super.key});

  @override
  State<PlatformPage> createState() => _PlatformPageState();
}

class _PlatformPageState extends State<PlatformPage> {
  late Map<String, dynamic> _platforms;
  late TextEditingController _presetController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final loadedModels = json.decode(prefs.getString("models") ?? "{}");
      _platforms.addAll(loadedModels);
      setState(() {});
    });

    final ai = context.read<AiPlatform>();
    _platforms = {ai.preset: ai.toMap()};
    _presetController = TextEditingController(text: ai.preset);
  }

  @override
  void dispose() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("models", json.encode(_platforms));
    });

    super.dispose();
  }

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
        body: Consumer<AiPlatform>(builder: (context, ai, child) {
          _platforms[ai.preset] = ai.toMap();

          SharedPreferences.getInstance().then((prefs) {
            prefs.setString("last_model", json.encode(ai.toMap()));
          });

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10.0),
                    Text(
                      ai.preset,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20.0),
                    FilledButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Consumer<AiPlatform>(
                                builder: (context, ai, child) {
                                  return AlertDialog(
                                    title: const Text(
                                      "Switch Model",
                                      textAlign: TextAlign.center,
                                    ),
                                    content: SizedBox(
                                      height: 200,
                                      width: 200,
                                      child: ListView.builder(
                                        itemCount: _platforms.keys.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final item =
                                              _platforms.keys.elementAt(index);

                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Dismissible(
                                              key: ValueKey(item),
                                              background:
                                                  Container(color: Colors.red),
                                              onDismissed: (direction) {
                                                setState(() {
                                                  _platforms.remove(item);
                                                  if (ai.preset == item) {
                                                    ai.fromMap(_platforms.values
                                                            .lastOrNull ??
                                                        {});
                                                  }
                                                });
                                                Logger.log(
                                                    "model Removed: $item");
                                                Navigator.of(context).pop();
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: ai.preset == item
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .tertiary
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(
                                                              15.0)),
                                                ),
                                                child: ListTile(
                                                  title: Text(
                                                    item,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  onTap: () {
                                                    ai.fromMap(
                                                        _platforms[item]);
                                                    Logger.log(
                                                        "Model Set: ${ai.preset}");
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0)),
                                    ),
                                    actions: [
                                      FilledButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          "Close",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge,
                                        ),
                                      ),
                                      FilledButton(
                                        onPressed: () {
                                          _platforms[ai.preset] = ai.toMap();
                                          ai.newPreset();
                                          _platforms[ai.preset] = ai.toMap();
                                          ai.notify();
                                        },
                                        child: Text(
                                          "New Preset",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            });
                      },
                      child: Text(
                        "Switch Preset",
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    TextFieldListTile(
                      headingText: "Preset Name",
                      labelText: "Preset",
                      controller: _presetController,
                      onChanged: (value) {
                        if (_platforms.keys.contains(value)) {
                          ai.fromMap(_platforms[value] ?? {});
                          Logger.log("Model Set: ${ai.preset}");
                        } else if (value.isNotEmpty) {
                          String oldName = ai.preset;
                          Logger.log("Updating model $oldName ====> $value");
                          ai.preset = value;
                          _platforms.remove(oldName);
                        }
                      },
                    ),
                    const SizedBox(height: 20.0),
                    Divider(
                      height: 20,
                      indent: 10,
                      endIndent: 10,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    DoubleButtonRow(
                      leftText: "Load Parameters",
                      leftOnPressed: () async {
                        await storageOperationDialog(
                            context, ai.importModelParameters);
                        setState(() {
                          _presetController.text = ai.preset;
                        });
                      },
                      rightText: "Save Parameters",
                      rightOnPressed: () async {
                        await storageOperationDialog(
                            context, ai.exportModelParameters);
                      },
                    ),
                    const SizedBox(height: 15.0),
                    FilledButton(
                      onPressed: () {
                        ai.reset();
                        setState(() {
                          _presetController.text = ai.preset;
                        });
                      },
                      child: Text(
                        "Reset All",
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    Divider(
                      height: 20,
                      indent: 10,
                      endIndent: 10,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    if (ai.apiType == AiPlatformType.local)
                      const LocalPlatform()
                    else if (ai.apiType == AiPlatformType.ollama)
                      const OllamaPlatform()
                    else if (ai.apiType == AiPlatformType.openAI)
                      const OpenAiPlatform()
                    else if (ai.apiType == AiPlatformType.mistralAI)
                      const MistralAiPlatform(),
                  ],
                ),
              ),
              if (context.watch<Session>().isBusy)
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
