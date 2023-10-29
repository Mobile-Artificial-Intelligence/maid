import 'package:flutter/material.dart';
import 'package:maid/config/model.dart';

class ModelPage extends StatefulWidget {
  const ModelPage({super.key});

  @override
  State<ModelPage> createState() => _ModelPageState();
}

class _ModelPageState extends State<ModelPage> {
  void _storageOperationDialog(Future<String> Function() storageFunction) async {
    String ret = await storageFunction();
    // Use a local reference to context to avoid using it across an async gap.
    final localContext = context;
    // Ensure that the context is still valid before attempting to show the dialog.
    if (localContext.mounted) {
      showDialog(
        context: localContext,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(ret),
            alignment: Alignment.center,
            actionsAlignment: MainAxisAlignment.center,
            backgroundColor: Theme.of(context).colorScheme.background,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            actions: [
              FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Close",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
            ],
          );
        },
      );
      model.saveSharedPreferences();
      setState(() {});
    }
  }

  @override
  initState() {
    super.initState();
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
                Text(
                  model.parameters["modelName"],
                  style: Theme.of(context).textTheme.titleSmall
                ),
                Divider(
                  indent: 10,
                  endIndent: 10,
                  color: Theme.of(context).colorScheme.primary,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: () {
                        _storageOperationDialog(model.loadModelFromJson);
                      },
                      child: Text(
                        "Load Model",
                        style: Theme.of(context).textTheme.labelLarge
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    FilledButton(
                      onPressed: () {
                        _storageOperationDialog(model.saveModelToJson);
                      },
                      child: Text(
                        "Save Model",
                        style: Theme.of(context).textTheme.labelLarge
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: () {
                        _storageOperationDialog(model.loadModelFile);
                      },
                      child: Text(
                        "Load Model",
                        style: Theme.of(context).textTheme.labelLarge
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    FilledButton(
                      onPressed: () {
                        model.resetAll();
                        setState(() {});
                      },
                      child: Text(
                        "Reset All",
                        style: Theme.of(context).textTheme.labelLarge
                      ),
                    ),
                  ],
                ),
                Divider(
                  indent: 10,
                  endIndent: 10,
                  color: Theme.of(context).colorScheme.primary,
                ),
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
                llamaParamSlider(
                  'n_threads', 
                  model.parameters["n_threads"],
                  1.0,
                  128.0,
                  127,
                  (value) => model.parameters["n_threads"] = value.round()
                ),
                llamaParamSlider(
                  'n_ctx',
                  model.parameters["n_ctx"],
                  1.0,
                  4096.0,
                  4095,
                  (value) => model.parameters["n_ctx"] = value.round()
                ),
                llamaParamSlider(
                  'n_batch',
                  model.parameters["n_batch"],
                  1.0,
                  4096.0,
                  4095,
                  (value) => model.parameters["n_batch"] = value.round()
                ),
                llamaParamSlider(
                  'n_predict',
                  model.parameters["n_predict"],
                  1.0,
                  1024.0,
                  1023,
                  (value) => model.parameters["n_predict"] = value.round()
                ),
                llamaParamSlider(
                  'n_keep',
                  model.parameters["n_keep"],
                  1.0,
                  1024.0,
                  1023,
                  (value) => model.parameters["n_keep"] = value.round()
                ),
                llamaParamSlider(
                  'n_prev',
                  model.parameters["n_prev"],
                  1.0,
                  1024.0,
                  1023,
                  (value) => model.parameters["n_prev"] = value.round()
                ),
                llamaParamSlider(
                  'n_probs',
                  model.parameters["n_probs"],
                  0.0,
                  128.0,
                  127,
                  (value) => model.parameters["n_probs"] = value.round()
                ),
                llamaParamSlider(
                  'top_k',
                  model.parameters["top_k"],
                  1.0,
                  128.0,
                  127,
                  (value) => model.parameters["top_k"] = value.round()
                ),
                llamaParamSlider(
                  'top_p',
                  model.parameters["top_p"],
                  0.0,
                  1.0,
                  100,
                  (value) => model.parameters["top_p"] = value
                ),
                llamaParamSlider(
                  'tfs_z',
                  model.parameters["tfs_z"],
                  0.0,
                  1.0,
                  100,
                  (value) => model.parameters["tfs_z"] = value
                ),
                llamaParamSlider(
                  'typical_p',
                  model.parameters["typical_p"],
                  0.0,
                  1.0,
                  100,
                  (value) => model.parameters["typical_p"] = value
                ),
                llamaParamSlider(
                  'temperature',
                  model.parameters["temperature"],
                  0.0,
                  1.0,
                  100,
                  (value) => model.parameters["temperature"] = value
                ),
                llamaParamSlider(
                  'penalty_last_n',
                  model.parameters["penalty_last_n"],
                  0.0,
                  128.0,
                  127,
                  (value) => model.parameters["penalty_last_n"] = value.round()
                ),
                llamaParamSlider(
                  'penalty_repeat',
                  model.parameters["penalty_repeat"],
                  0.0,
                  2.0,
                  200,
                  (value) => model.parameters["penalty_repeat"] = value
                ),
                llamaParamSlider(
                  'penalty_freq',
                  model.parameters["penalty_freq"],
                  0.0,
                  1.0,
                  100,
                  (value) => model.parameters["penalty_freq"] = value
                ),
                llamaParamSlider(
                  'penalty_present',
                  model.parameters["penalty_present"],
                  0.0,
                  1.0,
                  100,
                  (value) => model.parameters["penalty_present"] = value
                ),
                llamaParamSlider(
                  'mirostat',
                  model.parameters["mirostat"],
                  0.0,
                  128.0,
                  127,
                  (value) => model.parameters["mirostat"] = value.round()
                ),
                llamaParamSlider(
                  'mirostat_tau',
                  model.parameters["mirostat_tau"],
                  0.0,
                  10.0,
                  100,
                  (value) => model.parameters["mirostat_tau"] = value
                ),
                llamaParamSlider(
                  'mirostat_eta',
                  model.parameters["mirostat_eta"],
                  0.0,
                  1.0,
                  100,
                  (value) => model.parameters["mirostat_eta"] = value
                ),
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
      )
    );
  }

  Widget llamaParamTextField(String labelText, TextEditingController controller) {
    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: Text(labelText),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: labelText,
              )
            ),
          ),
        ],
      ),
    );
  }

  Widget llamaParamSlider(String labelText, num inputValue, 
    double sliderMin, double sliderMax, int sliderDivisions, 
    Function(double) onValueChanged
  ) {
    String labelValue;

    // I finput value is a double
    if (inputValue is int) {
      // If input value is an integer
      labelValue = inputValue.round().toString();
    } else {
      labelValue = inputValue.toStringAsFixed(3);
    }
    
    return ListTile(
      title: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(labelText),
          ),
          Expanded(
            flex: 7,
            child: Slider(
              value: inputValue.toDouble(),
              min: sliderMin,
              max: sliderMax,
              divisions: sliderDivisions,
              label: labelValue,
              onChanged: (double value) {
                setState(() {
                  onValueChanged(value);
                });
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(labelValue),
          ),
        ],
      ),
    );
  }
}

