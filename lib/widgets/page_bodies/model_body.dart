import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maid/static/generation_manager.dart';
import 'package:maid/static/logger.dart';
import 'package:maid/providers/model.dart';
import 'package:maid/widgets/dialogs.dart';
import 'package:maid/widgets/settings_widgets/double_button_row.dart';
import 'package:maid/widgets/settings_widgets/maid_slider.dart';
import 'package:maid/widgets/settings_widgets/maid_text_field.dart';
import 'package:maid/widgets/settings_widgets/remote_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModelBody extends StatefulWidget {
  const ModelBody({super.key});

  @override
  State<ModelBody> createState() => _ModelBodyState();
}

class _ModelBodyState extends State<ModelBody> {
  static Map<String, dynamic> _models = {};
  late Model cachedModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      _models = json.decode(prefs.getString("models") ?? "{}");
      setState(() {});
    });
  }

  @override
  void dispose() {
    SharedPreferences.getInstance().then((prefs) {
      _models[cachedModel.preset] = cachedModel.toMap();
      Logger.log("Model Saved: ${cachedModel.parameters["path"]}");

      prefs.setString("models", json.encode(_models));
      prefs.setString("last_model", json.encode(cachedModel.toMap()));
    });
    GenerationManager.cleanup();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Model>(
      builder: (context, model, child) {
        cachedModel = model;
        
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
                      switcherDialog(
                        context,
                        () {
                          return _models.keys.toList();
                        },
                        (String modelName) {
                          
                          model.fromMap(_models[modelName] ?? {});
                          Logger.log("Model Set: ${model.preset}");
                          
                        },
                        (String modelName) {
                          _models.remove(modelName);
                          String? key = _models.keys.lastOrNull;

                          if (key == null) {
                            model.resetAll();
                          } else {
                            model.fromMap(_models[key]!);
                          }
                          
                        },
                        (String modelName) {
                          return model.preset == modelName;
                        },
                        () => setState(() {}), 
                        () async {
                          final prefs = await SharedPreferences.getInstance();
                          _models[model.preset] = model.toMap();
                          Logger.log("Model Saved: ${model.preset}");
                          
                          prefs.setString("models", json.encode(_models));
                          prefs.setString("last_model", model.preset);

                          GenerationManager.cleanup();

                          model.resetAll();
                          model.setPreset("New Preset");
                        }
                      );
                    },
                    child: Text(
                      "Switch Preset",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  MaidTextField(
                    headingText: "Preset Name",
                    labelText: "Preset",
                    initialValue: model.preset,
                    onSubmitted: (value) {
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
                  Text(
                    "Remote Model",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 20.0),
                  MaidTextField(
                    headingText: 'Remote URL', 
                    labelText: 'Remote URL',
                    initialValue: model.parameters["remote_url"] ?? "http://0.0.0.0:11434",
                    onSubmitted: (value) {
                      model.setParameter("remote_url", value);
                    } ,
                  ),
                  const SizedBox(height: 8.0),
                  RemoteDropdown(url: model.parameters["remote_url"] ?? "http://0.0.0.0:11434"),
                  const SizedBox(height: 20.0),
                  Divider(
                    height: 20,
                    indent: 10,
                    endIndent: 10,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Text(
                    "Local Model",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 20.0),
                  if (model.local) ...[
                    ListTile(
                      title: Row(
                        children: [
                          const Expanded(
                            child: Text("Model Path"),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              model.parameters["path"],
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15.0),
                  ],
                  DoubleButtonRow(
                      leftText: "Load GGUF",
                      leftOnPressed: () {
                        storageOperationDialog(
                          context, 
                          model.loadModelFile
                        ).then((value) {
                          if (model.parameters["path"] != null) {
                            model.setLocal(true);
                          }
                        });
                      },
                      rightText: "Unload GGUF",
                      rightOnPressed: () {
                        model.setParameter("path", null);
                        model.setLocal(false);
                      }),
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
                    },
                    child: Text(
                      "Reset All",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  if (model.local) ...[
                    SwitchListTile(
                      title: const Text('instruct'),
                      value: model.parameters["instruct"] ?? true,
                      onChanged: (value) {
                        setState(() {
                          model.setParameter("instruct", value);
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('interactive'),
                      value: model.parameters["interactive"] ?? true,
                      onChanged: (value) {
                        setState(() {
                          model.setParameter("interactive", value);
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('memory_f16'),
                      value: model.parameters["memory_f16"] ?? false,
                      onChanged: (value) {
                        setState(() {
                          model.setParameter("memory_f16", value);
                        });
                      },
                    )
                  ],
                  SwitchListTile(
                    title: const Text('penalize_nl'),
                    value: model.parameters["penalize_nl"] ?? true,
                    onChanged: (value) {
                      setState(() {
                        model.setParameter("penalize_nl", value);
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('random_seed'),
                    value: model.parameters["random_seed"] ?? true,
                    onChanged: (value) {
                      setState(() {
                        model.setParameter("random_seed", value);
                      });
                    },
                  ),
                  Divider(
                    height: 20,
                    indent: 10,
                    endIndent: 10,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  if (!(model.parameters["random_seed"] ?? true))
                    ListTile(
                      title: Row(
                        children: [
                          const Expanded(
                            child: Text('seed'),
                          ),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'seed',
                              ),
                              onSubmitted: (value) {
                                model.setParameter("seed", int.parse(value));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  MaidSlider(
                      labelText: 'n_threads',
                      inputValue: model.parameters["n_threads"] ?? Platform.numberOfProcessors,
                      sliderMin: 1.0,
                      sliderMax: !GenerationManager.remote
                          ? Platform.numberOfProcessors.toDouble()
                          : 128.0,
                      sliderDivisions: 127,
                      onValueChanged: (value) => {
                            setState(() {
                              model.setParameter("n_threads", value.round());
                              if (model.parameters["n_threads"] > Platform.numberOfProcessors) {
                                model.setParameter("n_threads", Platform.numberOfProcessors);
                              }
                            })
                          }),
                  MaidSlider(
                      labelText: 'n_ctx',
                      inputValue: model.parameters["n_ctx"] ?? 512,
                      sliderMin: 1.0,
                      sliderMax: 4096.0,
                      sliderDivisions: 4095,
                      onValueChanged: (value) => {
                            setState(() {
                              model.setParameter("n_ctx", value.round());
                            })
                          }),
                  MaidSlider(
                      labelText: 'n_batch',
                      inputValue: model.parameters["n_batch"] ?? 8,
                      sliderMin: 1.0,
                      sliderMax: 4096.0,
                      sliderDivisions: 4095,
                      onValueChanged: (value) => {
                            setState(() {
                              model.setParameter("n_batch", value.round());
                            })
                          }),
                  MaidSlider(
                      labelText: 'n_predict',
                      inputValue: model.parameters["n_predict"] ?? 512,
                      sliderMin: 1.0,
                      sliderMax: 1024.0,
                      sliderDivisions: 1023,
                      onValueChanged: (value) => {
                            setState(() {
                              model.setParameter("n_predict", value.round());
                            })
                          }),
                  MaidSlider(
                      labelText: 'n_keep',
                      inputValue: model.parameters["n_keep"] ?? 48,
                      sliderMin: 1.0,
                      sliderMax: 1024.0,
                      sliderDivisions: 1023,
                      onValueChanged: (value) => {
                            setState(() {
                              model.setParameter("n_keep", value.round());
                            })
                          }),
                  MaidSlider(
                      labelText: 'top_k',
                      inputValue: model.parameters["top_k"] ?? 40,
                      sliderMin: 1.0,
                      sliderMax: 128.0,
                      sliderDivisions: 127,
                      onValueChanged: (value) => {
                            setState(() {
                              model.setParameter("top_k", value.round());
                            })
                          }),
                  MaidSlider(
                      labelText: 'top_p',
                      inputValue: model.parameters["top_p"] ?? 0.95,
                      sliderMin: 0.0,
                      sliderMax: 1.0,
                      sliderDivisions: 100,
                      onValueChanged: (value) => {
                            setState(() {
                              model.setParameter("top_p", value);
                            })
                          }),
                  MaidSlider(
                      labelText: 'tfs_z',
                      inputValue: model.parameters["tfs_z"] ?? 1.0,
                      sliderMin: 0.0,
                      sliderMax: 1.0,
                      sliderDivisions: 100,
                      onValueChanged: (value) => {
                            setState(() {
                              model.setParameter("tfs_z", value);
                            })
                          }),
                  MaidSlider(
                      labelText: 'typical_p',
                      inputValue: model.parameters["typical_p"] ?? 1.0,
                      sliderMin: 0.0,
                      sliderMax: 1.0,
                      sliderDivisions: 100,
                      onValueChanged: (value) => {
                            setState(() {
                              model.setParameter("typical_p", value);
                            })
                          }),
                  MaidSlider(
                      labelText: 'temperature',
                      inputValue: model.parameters["temperature"] ?? 0.8,
                      sliderMin: 0.0,
                      sliderMax: 1.0,
                      sliderDivisions: 100,
                      onValueChanged: (value) => {
                            setState(() {
                              model.setParameter("temperature", value);
                            })
                          }),
                  MaidSlider(
                      labelText: 'penalty_last_n',
                      inputValue: model.parameters["penalty_last_n"] ?? 64,
                      sliderMin: 0.0,
                      sliderMax: 128.0,
                      sliderDivisions: 127,
                      onValueChanged: (value) => {
                            setState(() {
                              model.setParameter("penalty_last_n", value.round());
                            })
                          }),
                  MaidSlider(
                      labelText: 'penalty_repeat',
                      inputValue: model.parameters["penalty_repeat"] ?? 1.1,
                      sliderMin: 0.0,
                      sliderMax: 2.0,
                      sliderDivisions: 200,
                      onValueChanged: (value) => {
                            setState(() {
                              model.setParameter("penalty_repeat", value);
                            })
                          }),
                  MaidSlider(
                      labelText: 'penalty_freq',
                      inputValue: model.parameters["penalty_freq"] ?? 0.0,
                      sliderMin: 0.0,
                      sliderMax: 1.0,
                      sliderDivisions: 100,
                      onValueChanged: (value) => {
                            setState(() {
                              model.setParameter("penalty_freq", value);
                            })
                          }),
                  MaidSlider(
                      labelText: 'penalty_present',
                      inputValue: model.parameters["penalty_present"] ?? 0.0,
                      sliderMin: 0.0,
                      sliderMax: 1.0,
                      sliderDivisions: 100,
                      onValueChanged: (value) => {
                            setState(() {
                              model.setParameter("penalty_present", value);
                            })
                          }),
                  MaidSlider(
                      labelText: 'mirostat',
                      inputValue: model.parameters["mirostat"] ?? 0.0,
                      sliderMin: 0.0,
                      sliderMax: 128.0,
                      sliderDivisions: 127,
                      onValueChanged: (value) => {
                            setState(() {
                              model.setParameter("mirostat", value.round());
                            })
                          }),
                  MaidSlider(
                      labelText: 'mirostat_tau',
                      inputValue: model.parameters["mirostat_tau"] ?? 5.0,
                      sliderMin: 0.0,
                      sliderMax: 10.0,
                      sliderDivisions: 100,
                      onValueChanged: (value) => {
                            setState(() {
                              model.setParameter("mirostat_tau", value);
                            })
                          }),
                  MaidSlider(
                      labelText: 'mirostat_eta',
                      inputValue: model.parameters["mirostat_eta"] ?? 0.1,
                      sliderMin: 0.0,
                      sliderMax: 1.0,
                      sliderDivisions: 100,
                      onValueChanged: (value) => {
                            setState(() {
                              model.setParameter("mirostat_eta", value);
                            })
                          }),
                ],
              ),
            ),
            if (GenerationManager.busy)
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
      }
    );
  }
  
}