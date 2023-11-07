import 'package:flutter/material.dart';
import 'package:maid/utilities/model.dart';
import 'package:maid/utilities/memory_manager.dart';
import 'package:maid/widgets/dialogs.dart';
import 'package:maid/widgets/settings_widgets/double_button_row.dart';
import 'package:maid/widgets/settings_widgets/maid_dropdown.dart';
import 'package:maid/widgets/settings_widgets/maid_slider.dart';

class ModelPage extends StatefulWidget {
  const ModelPage({super.key});

  @override
  State<ModelPage> createState() => _ModelPageState();
}

class _ModelPageState extends State<ModelPage> {
  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    memoryManager.save();
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
                  MaidDropDown(
                    initialSelection: model.name, 
                    getMenuStrings: memoryManager.getModels,
                    update: memoryManager.updateModel,
                    set: memoryManager.setModel,
                  ),
                  const SizedBox(height: 15.0),
                  DoubleButtonRow(
                    leftText: "New Preset",
                    leftOnPressed: () async {
                      await memoryManager.save();
                      model = Model();
                      model.name = "New Preset";
                      setState(() {});
                    },
                    rightText: "Delete Preset",
                    rightOnPressed: () async {
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
                  DoubleButtonRow(
                    
                    leftText: "Load Model",
                    leftOnPressed: () async {
                      await storageOperationDialog(context, model.loadModelFile);
                      setState(() {});
                    },
                    rightText: "Reset All",
                    rightOnPressed: () {
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
                  DoubleButtonRow(
                    
                    leftText: "Load Parameters",
                    leftOnPressed: () async {
                      await storageOperationDialog(
                          context, model.loadParametersFromJson);
                      setState(() {});
                    },
                    rightText: "Save Parameters",
                    rightOnPressed: () async {
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
                  MaidSlider(
                      labelText: 'n_threads',
                      inputValue: model.parameters["n_threads"],
                      sliderMin: 1.0,
                      sliderMax: 128.0,
                      sliderDivisions: 127,
                      onValueChanged: (value) => {
                            setState(() {
                              model.parameters["n_threads"] = value.round();
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
                      labelText: 'n_prev',
                      inputValue: model.parameters["n_prev"],
                      sliderMin: 1.0,
                      sliderMax: 1024.0,
                      sliderDivisions: 1023,
                      onValueChanged: (value) => {
                            setState(() {
                              model.parameters["n_prev"] = value.round();
                            })
                          }),
                  MaidSlider(
                      labelText: 'n_probs',
                      inputValue: model.parameters["n_probs"],
                      sliderMin: 0.0,
                      sliderMax: 128.0,
                      sliderDivisions: 127,
                      onValueChanged: (value) => {
                            setState(() {
                              model.parameters["n_probs"] = value.round();
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
