import 'package:flutter/material.dart';
import 'package:maid/utilities/model.dart';
import 'package:maid/utilities/memory_manager.dart';
import 'package:maid/widgets/settings_widgets.dart';

class ModelPage extends StatefulWidget {
  const ModelPage({super.key});

  @override
  State<ModelPage> createState() => _ModelPageState();
}

class _ModelPageState extends State<ModelPage> {
  TextEditingController presetController = TextEditingController();

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    memoryManager.save();
    presetController.dispose();
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
          title: const Text('Model'),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10.0),
                  DropdownMenu<String>(
                    width: 200.0,
                    initialSelection: model.name,
                    controller: presetController,
                    dropdownMenuEntries: memoryManager
                        .getModels()
                        .map<DropdownMenuEntry<String>>(
                      (String value) {
                        return DropdownMenuEntry<String>(
                          value: value,
                          label: value,
                        );
                      },
                    ).toList(),
                    onSelected: (value) => setState(() async {
                      if (value == null) {
                        await memoryManager.updateModel(presetController.text);
                      } else {
                        await memoryManager.setModel(value);
                      }
                      setState(() {});
                    }),
                  ),
                  const SizedBox(height: 15.0),
                  doubleButtonRow(
                    context,
                    "New Preset",
                    () async {
                      await memoryManager.save();
                      model = Model();
                      model.name = "New Preset";
                      setState(() {});
                    },
                    "Delete Preset",
                    () async {
                      await memoryManager.removeModel();
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Model Name: ${model.parameters["model_name"]}",
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Model Path: ${model.parameters["model_path"]}",
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  doubleButtonRow(
                    context,
                    "Load Model",
                    () async {
                      await storageOperationDialog(context, model.loadModelFile);
                      setState(() {});
                    },
                    "Reset All",
                    () {
                      model.resetAll();
                      setState(() {});
                    },
                  ),
                  Divider(
                    height: 20,
                    indent: 10,
                    endIndent: 10,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  doubleButtonRow(
                    context,
                    "Load Parameters",
                    () async {
                      await storageOperationDialog(
                          context, model.loadParametersFromJson);
                      setState(() {});
                    },
                    "Save Parameters",
                    () async {
                      await storageOperationDialog(context, model.saveParametersToJson);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 15.0),
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
                  ),
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
                              onChanged: (value) {
                                model.parameters["seed"] = int.parse(value);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  settingsSlider(
                      'n_threads',
                      model.parameters["n_threads"],
                      1.0,
                      128.0,
                      127,
                      (value) => {
                            setState(() {
                              model.parameters["n_threads"] = value.round();
                            })
                          }),
                  settingsSlider(
                      'n_ctx',
                      model.parameters["n_ctx"],
                      1.0,
                      4096.0,
                      4095,
                      (value) => {
                            setState(() {
                              model.parameters["n_ctx"] = value.round();
                            })
                          }),
                  settingsSlider(
                      'n_batch',
                      model.parameters["n_batch"],
                      1.0,
                      4096.0,
                      4095,
                      (value) => {
                            setState(() {
                              model.parameters["n_batch"] = value.round();
                            })
                          }),
                  settingsSlider(
                      'n_predict',
                      model.parameters["n_predict"],
                      1.0,
                      1024.0,
                      1023,
                      (value) => {
                            setState(() {
                              model.parameters["n_predict"] = value.round();
                            })
                          }),
                  settingsSlider(
                      'n_keep',
                      model.parameters["n_keep"],
                      1.0,
                      1024.0,
                      1023,
                      (value) => {
                            setState(() {
                              model.parameters["n_keep"] = value.round();
                            })
                          }),
                  settingsSlider(
                      'n_prev',
                      model.parameters["n_prev"],
                      1.0,
                      1024.0,
                      1023,
                      (value) => {
                            setState(() {
                              model.parameters["n_prev"] = value.round();
                            })
                          }),
                  settingsSlider(
                      'n_probs',
                      model.parameters["n_probs"],
                      0.0,
                      128.0,
                      127,
                      (value) => {
                            setState(() {
                              model.parameters["n_probs"] = value.round();
                            })
                          }),
                  settingsSlider(
                      'top_k',
                      model.parameters["top_k"],
                      1.0,
                      128.0,
                      127,
                      (value) => {
                            setState(() {
                              model.parameters["top_k"] = value.round();
                            })
                          }),
                  settingsSlider(
                      'top_p',
                      model.parameters["top_p"],
                      0.0,
                      1.0,
                      100,
                      (value) => {
                            setState(() {
                              model.parameters["top_p"] = value;
                            })
                          }),
                  settingsSlider(
                      'tfs_z',
                      model.parameters["tfs_z"],
                      0.0,
                      1.0,
                      100,
                      (value) => {
                            setState(() {
                              model.parameters["tfs_z"] = value;
                            })
                          }),
                  settingsSlider(
                      'typical_p',
                      model.parameters["typical_p"],
                      0.0,
                      1.0,
                      100,
                      (value) => {
                            setState(() {
                              model.parameters["typical_p"] = value;
                            })
                          }),
                  settingsSlider(
                      'temperature',
                      model.parameters["temperature"],
                      0.0,
                      1.0,
                      100,
                      (value) => {
                            setState(() {
                              model.parameters["temperature"] = value;
                            })
                          }),
                  settingsSlider(
                      'penalty_last_n',
                      model.parameters["penalty_last_n"],
                      0.0,
                      128.0,
                      127,
                      (value) => {
                            setState(() {
                              model.parameters["penalty_last_n"] =
                                  value.round();
                            })
                          }),
                  settingsSlider(
                      'penalty_repeat',
                      model.parameters["penalty_repeat"],
                      0.0,
                      2.0,
                      200,
                      (value) => {
                            setState(() {
                              model.parameters["penalty_repeat"] = value;
                            })
                          }),
                  settingsSlider(
                      'penalty_freq',
                      model.parameters["penalty_freq"],
                      0.0,
                      1.0,
                      100,
                      (value) => {
                            setState(() {
                              model.parameters["penalty_freq"] = value;
                            })
                          }),
                  settingsSlider(
                      'penalty_present',
                      model.parameters["penalty_present"],
                      0.0,
                      1.0,
                      100,
                      (value) => {
                            setState(() {
                              model.parameters["penalty_present"] = value;
                            })
                          }),
                  settingsSlider(
                      'mirostat',
                      model.parameters["mirostat"],
                      0.0,
                      128.0,
                      127,
                      (value) => {
                            setState(() {
                              model.parameters["mirostat"] = value.round();
                            })
                          }),
                  settingsSlider(
                      'mirostat_tau',
                      model.parameters["mirostat_tau"],
                      0.0,
                      10.0,
                      100,
                      (value) => {
                            setState(() {
                              model.parameters["mirostat_tau"] = value;
                            })
                          }),
                  settingsSlider(
                      'mirostat_eta',
                      model.parameters["mirostat_eta"],
                      0.0,
                      1.0,
                      100,
                      (value) => {
                            setState(() {
                              model.parameters["mirostat_eta"] = value;
                            })
                          }),
                ],
              ),
            ),
            if (model.busy)
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
        ));
  }
}
