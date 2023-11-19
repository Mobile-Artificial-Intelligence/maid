import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maid/static/generation_manager.dart';
import 'package:maid/static/host.dart';
import 'package:maid/static/memory_manager.dart';
import 'package:maid/static/message_manager.dart';
import 'package:maid/types/model.dart';
import 'package:maid/widgets/dialogs.dart';
import 'package:maid/widgets/settings_widgets/double_button_row.dart';
import 'package:maid/widgets/settings_widgets/maid_slider.dart';
import 'package:maid/widgets/settings_widgets/maid_text_field.dart';

class ModelBody extends StatefulWidget {
  const ModelBody({super.key});

  @override
  State<ModelBody> createState() => _ModelBodyState();
}

class _ModelBodyState extends State<ModelBody> {
  @override
  void dispose() {
    MemoryManager.saveModels();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      MemoryManager.getModels,
                      MemoryManager.setModel,
                      MemoryManager.removeModel,
                      MemoryManager.isCurrentModel,
                      () => setState(() {}), () async {
                    MemoryManager.saveModels();
                    model = Model();
                    model.preset = "New Preset";
                    setState(() {});
                  });
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
                  if (MemoryManager.getModels().contains(value)) {
                    MemoryManager.setModel(value);
                  } else if (value.isNotEmpty) {
                    MemoryManager.updateModel(value);
                  }
                  setState(() {});
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
                initialValue: Host.url,
                onChanged: (value) {
                  Host.url = value;
                },
              ),
              const SizedBox(height: 20.0),
              MaidTextField(
                headingText: "Remote Model",
                labelText: "Model",
                initialValue: model.parameters["remote_model"],
                onChanged: (value) {
                  model.parameters["remote_model"] = value;
                },
              ),
              const SizedBox(height: 8.0),
              MaidTextField(
                headingText: "Remote Tag",
                labelText: "Tag",
                initialValue: model.parameters["remote_tag"],
                onChanged: (value) {
                  model.parameters["remote_tag"] = value;
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
                  leftOnPressed: () async {
                    await storageOperationDialog(
                        context, model.loadModelFile);
                    if (model.parameters["path"] != null) {
                      model.local = true;
                    }
                    setState(() {});
                  },
                  rightText: "Unload GGUF",
                  rightOnPressed: () {
                    model.parameters["path"] = null;
                    model.local = false;
                    setState(() {});
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
                  setState(() {});
                },
                rightText: "Save Parameters",
                rightOnPressed: () async {
                  await storageOperationDialog(
                      context, model.exportModelParameters);
                  setState(() {});
                },
              ),
              const SizedBox(height: 15.0),
              FilledButton(
                onPressed: () {
                  model.resetAll();
                  setState(() {});
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
                  value: model.parameters["instruct"],
                  onChanged: (value) {
                    setState(() {
                      model.parameters["instruct"] = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('interactive'),
                  value: model.parameters["interactive"],
                  onChanged: (value) {
                    setState(() {
                      model.parameters["interactive"] = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('memory_f16'),
                  value: model.parameters["memory_f16"],
                  onChanged: (value) {
                    setState(() {
                      model.parameters["memory_f16"] = value;
                    });
                  },
                )
              ],
              SwitchListTile(
                title: const Text('penalize_nl'),
                value: model.parameters["penalize_nl"],
                onChanged: (value) {
                  setState(() {
                    model.parameters["penalize_nl"] = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('random_seed'),
                value: model.parameters["random_seed"],
                onChanged: (value) {
                  setState(() {
                    model.parameters["random_seed"] = value;
                  });
                },
              ),
              Divider(
                height: 20,
                indent: 10,
                endIndent: 10,
                color: Theme.of(context).colorScheme.primary,
              ),
              if (!model.parameters["random_seed"])
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
                            model.parameters["seed"] = int.parse(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              MaidSlider(
                  labelText: 'n_threads',
                  inputValue: model.parameters["n_threads"],
                  sliderMin: 1.0,
                  sliderMax: !GenerationManager.remote
                      ? Platform.numberOfProcessors.toDouble()
                      : 128.0,
                  sliderDivisions: 127,
                  onValueChanged: (value) => {
                        setState(() {
                          model.parameters["n_threads"] = value.round();
                          if (model.parameters["n_threads"] > Platform.numberOfProcessors) {
                            model.parameters["n_threads"] = Platform.numberOfProcessors;
                          }
                        })
                      }),
              MaidSlider(
                  labelText: 'n_ctx',
                  inputValue: model.parameters["n_ctx"],
                  sliderMin: 1.0,
                  sliderMax: 4096.0,
                  sliderDivisions: 4095,
                  onValueChanged: (value) => {
                        setState(() {
                          model.parameters["n_ctx"] = value.round();
                        })
                      }),
              MaidSlider(
                  labelText: 'n_batch',
                  inputValue: model.parameters["n_batch"],
                  sliderMin: 1.0,
                  sliderMax: 4096.0,
                  sliderDivisions: 4095,
                  onValueChanged: (value) => {
                        setState(() {
                          model.parameters["n_batch"] = value.round();
                        })
                      }),
              MaidSlider(
                  labelText: 'n_predict',
                  inputValue: model.parameters["n_predict"],
                  sliderMin: 1.0,
                  sliderMax: 1024.0,
                  sliderDivisions: 1023,
                  onValueChanged: (value) => {
                        setState(() {
                          model.parameters["n_predict"] = value.round();
                        })
                      }),
              MaidSlider(
                  labelText: 'n_keep',
                  inputValue: model.parameters["n_keep"],
                  sliderMin: 1.0,
                  sliderMax: 1024.0,
                  sliderDivisions: 1023,
                  onValueChanged: (value) => {
                        setState(() {
                          model.parameters["n_keep"] = value.round();
                        })
                      }),
              MaidSlider(
                  labelText: 'top_k',
                  inputValue: model.parameters["top_k"],
                  sliderMin: 1.0,
                  sliderMax: 128.0,
                  sliderDivisions: 127,
                  onValueChanged: (value) => {
                        setState(() {
                          model.parameters["top_k"] = value.round();
                        })
                      }),
              MaidSlider(
                  labelText: 'top_p',
                  inputValue: model.parameters["top_p"],
                  sliderMin: 0.0,
                  sliderMax: 1.0,
                  sliderDivisions: 100,
                  onValueChanged: (value) => {
                        setState(() {
                          model.parameters["top_p"] = value;
                        })
                      }),
              MaidSlider(
                  labelText: 'tfs_z',
                  inputValue: model.parameters["tfs_z"],
                  sliderMin: 0.0,
                  sliderMax: 1.0,
                  sliderDivisions: 100,
                  onValueChanged: (value) => {
                        setState(() {
                          model.parameters["tfs_z"] = value;
                        })
                      }),
              MaidSlider(
                  labelText: 'typical_p',
                  inputValue: model.parameters["typical_p"],
                  sliderMin: 0.0,
                  sliderMax: 1.0,
                  sliderDivisions: 100,
                  onValueChanged: (value) => {
                        setState(() {
                          model.parameters["typical_p"] = value;
                        })
                      }),
              MaidSlider(
                  labelText: 'temperature',
                  inputValue: model.parameters["temperature"],
                  sliderMin: 0.0,
                  sliderMax: 1.0,
                  sliderDivisions: 100,
                  onValueChanged: (value) => {
                        setState(() {
                          model.parameters["temperature"] = value;
                        })
                      }),
              MaidSlider(
                  labelText: 'penalty_last_n',
                  inputValue: model.parameters["penalty_last_n"],
                  sliderMin: 0.0,
                  sliderMax: 128.0,
                  sliderDivisions: 127,
                  onValueChanged: (value) => {
                        setState(() {
                          model.parameters["penalty_last_n"] =
                              value.round();
                        })
                      }),
              MaidSlider(
                  labelText: 'penalty_repeat',
                  inputValue: model.parameters["penalty_repeat"],
                  sliderMin: 0.0,
                  sliderMax: 2.0,
                  sliderDivisions: 200,
                  onValueChanged: (value) => {
                        setState(() {
                          model.parameters["penalty_repeat"] = value;
                        })
                      }),
              MaidSlider(
                  labelText: 'penalty_freq',
                  inputValue: model.parameters["penalty_freq"],
                  sliderMin: 0.0,
                  sliderMax: 1.0,
                  sliderDivisions: 100,
                  onValueChanged: (value) => {
                        setState(() {
                          model.parameters["penalty_freq"] = value;
                        })
                      }),
              MaidSlider(
                  labelText: 'penalty_present',
                  inputValue: model.parameters["penalty_present"],
                  sliderMin: 0.0,
                  sliderMax: 1.0,
                  sliderDivisions: 100,
                  onValueChanged: (value) => {
                        setState(() {
                          model.parameters["penalty_present"] = value;
                        })
                      }),
              MaidSlider(
                  labelText: 'mirostat',
                  inputValue: model.parameters["mirostat"],
                  sliderMin: 0.0,
                  sliderMax: 128.0,
                  sliderDivisions: 127,
                  onValueChanged: (value) => {
                        setState(() {
                          model.parameters["mirostat"] = value.round();
                        })
                      }),
              MaidSlider(
                  labelText: 'mirostat_tau',
                  inputValue: model.parameters["mirostat_tau"],
                  sliderMin: 0.0,
                  sliderMax: 10.0,
                  sliderDivisions: 100,
                  onValueChanged: (value) => {
                        setState(() {
                          model.parameters["mirostat_tau"] = value;
                        })
                      }),
              MaidSlider(
                  labelText: 'mirostat_eta',
                  inputValue: model.parameters["mirostat_eta"],
                  sliderMin: 0.0,
                  sliderMax: 1.0,
                  sliderDivisions: 100,
                  onValueChanged: (value) => {
                        setState(() {
                          model.parameters["mirostat_eta"] = value;
                        })
                      }),
            ],
          ),
        ),
        if (MessageManager.busy)
          // This is a semi-transparent overlay that will cover the entire screen.
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
  
}