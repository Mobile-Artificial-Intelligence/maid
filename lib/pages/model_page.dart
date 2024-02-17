import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/static/logger.dart';
import 'package:maid/providers/model.dart';
import 'package:maid/widgets/platform_widgets/local_platform.dart';
import 'package:maid/widgets/platform_widgets/mistralai_platform.dart';
import 'package:maid/widgets/platform_widgets/ollama_platform.dart';
import 'package:maid/widgets/platform_widgets/openai_platform.dart';
import 'package:maid/widgets/dialogs.dart';
import 'package:maid/widgets/dropdowns/api_dropdown.dart';
import 'package:maid/widgets/double_button_row.dart';
import 'package:maid/widgets/text_field_list_tile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModelPage extends StatefulWidget {
  const ModelPage({super.key});

  @override
  State<ModelPage> createState() => _ModelPageState();
}

class _ModelPageState extends State<ModelPage> {
  static Map<String, dynamic> _models = {};
  late Model cachedModel;
  late TextEditingController _presetController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final loadedModels = json.decode(prefs.getString("models") ?? "{}");
      _models.addAll(loadedModels);
      setState(() {});
    });

    final model = context.read<Model>();
    _models[model.preset] = model.toMap();
    _presetController = TextEditingController(text: model.preset);
  }

  @override
  void dispose() {
    SharedPreferences.getInstance().then((prefs) {
      _models[cachedModel.preset] = cachedModel.toMap();
      Logger.log("Model Saved: ${cachedModel.parameters["path"]}");

      prefs.setString("models", json.encode(_models));
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
        body: Consumer<Model>(builder: (context, model, child) {
          cachedModel = model;

          if (_models.isEmpty) {
            _models[model.preset] = model.toMap();
          }

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10.0),
                    Text(
                      model.preset,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20.0),
                    FilledButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Consumer<Model>(
                                builder: (context, model, child) {
                                  return AlertDialog(
                                    title: const Text(
                                      "Switch Model",
                                      textAlign: TextAlign.center,
                                    ),
                                    content: SizedBox(
                                      height: 200,
                                      width: 200,
                                      child: ListView.builder(
                                        itemCount: _models.keys.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final item =
                                              _models.keys.elementAt(index);

                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Dismissible(
                                              key: ValueKey(item),
                                              background:
                                                  Container(color: Colors.red),
                                              onDismissed: (direction) {
                                                setState(() {
                                                  _models.remove(item);
                                                  if (model.preset == item) {
                                                    model.fromMap(_models.values
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
                                                  color: model.preset == item
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
                                                    model
                                                        .fromMap(_models[item]);
                                                    Logger.log(
                                                        "Model Set: ${model.preset}");
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
                                          _models[model.preset] = model.toMap();
                                          model.newPreset();
                                          _models[model.preset] = model.toMap();
                                          model.notify();
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
                        if (_models.keys.contains(value)) {
                          model.fromMap(_models[value] ?? {});
                          Logger.log("Model Set: ${model.preset}");
                        } else if (value.isNotEmpty) {
                          String oldName = model.preset;
                          Logger.log("Updating model $oldName ====> $value");
                          model.setPreset(value);
                          _models.remove(oldName);
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
                            context, model.importModelParameters);
                        setState(() {
                          _presetController.text = model.preset;
                        });
                      },
                      rightText: "Save Parameters",
                      rightOnPressed: () async {
                        await storageOperationDialog(
                            context, model.exportModelParameters);
                      },
                    ),
                    const SizedBox(height: 15.0),
                    FilledButton(
                      onPressed: () {
                        model.resetAll();
                        setState(() {
                          _presetController.text = model.preset;
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
                    const ApiDropdown(),
                    if (model.apiType == ApiType.local)
                      const LocalPlatform()
                    else if (model.apiType == ApiType.ollama)
                      const OllamaPlatform()
                    else if (model.apiType == ApiType.openAI)
                      const OpenAiPlatform()
                    else if (model.apiType == ApiType.mistralAI)
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
