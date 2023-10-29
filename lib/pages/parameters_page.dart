import 'package:flutter/material.dart';
import 'package:maid/settings.dart';

class ParametersPage extends StatefulWidget {
  const ParametersPage({super.key});

  @override
  State<ParametersPage> createState() => _ParametersPageState();
}

class _ParametersPageState extends State<ParametersPage> {
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
      parameters.saveSharedPreferences();
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
        title: const Text('Parameters'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10.0),
                Text(
                  parameters.parameters["modelName"],
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
                        _storageOperationDialog(parameters.loadParametersFromJson);
                      },
                      child: Text(
                        "Load Parameters",
                        style: Theme.of(context).textTheme.labelLarge
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    FilledButton(
                      onPressed: () {
                        _storageOperationDialog(parameters.saveParametersToJson);
                      },
                      child: Text(
                        "Save Parameters",
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
                        _storageOperationDialog(parameters.loadModelFile);
                      },
                      child: Text(
                        "Load Model",
                        style: Theme.of(context).textTheme.labelLarge
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    FilledButton(
                      onPressed: () {
                        parameters.resetAll();
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
                llamaParamTextField(
                  'User alias', parameters.userAliasController),
                llamaParamTextField(
                  'Response alias', parameters.responseAliasController),
                ListTile(
                  title: Row(
                    children: [
                      const Expanded(
                        child: Text('PrePrompt'),
                      ),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          controller: parameters.prePromptController,
                          decoration: const InputDecoration(
                            labelText: 'PrePrompt',
                          ),
                        ),
                      ),
                    ],
                  ),
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
                        setState(() {
                          parameters.examplePromptControllers.add(TextEditingController());
                          parameters.exampleResponseControllers.add(TextEditingController());
                        });
                      },
                      child: Text(
                        "Add Example",
                        style: Theme.of(context).textTheme.labelLarge
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          parameters.examplePromptControllers.removeLast();
                          parameters.exampleResponseControllers.removeLast();
                        });
                      },
                      child: Text(
                        "Remove Example",
                        style: Theme.of(context).textTheme.labelLarge
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                ...List.generate(
                  (parameters.examplePromptControllers.length == parameters.exampleResponseControllers.length) ? parameters.examplePromptControllers.length : 0,
                  (index) => Column(
                    children: [
                      llamaParamTextField('Example prompt', parameters.examplePromptControllers[index]),
                      llamaParamTextField('Example response', parameters.exampleResponseControllers[index]),
                    ],
                  ),
                ),
                Divider(
                  indent: 10,
                  endIndent: 10,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SwitchListTile(
                  title: const Text('instruct'),
                  value: parameters.parameters["instruct"],
                  onChanged: (value) {
                    setState(() {
                      parameters.parameters["instruct"] = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('memory_f16'),
                  value: parameters.parameters["memory_f16"],
                  onChanged: (value) {
                    setState(() {
                      parameters.parameters["memory_f16"] = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('penalize_nl'),
                  value: parameters.parameters["penalize_nl"],
                  onChanged: (value) {
                    setState(() {
                      parameters.parameters["penalize_nl"] = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('random_seed'),
                  value: parameters.parameters["random_seed"],
                  onChanged: (value) {
                    setState(() {
                      parameters.parameters["random_seed"] = value;
                    });
                  },
                ),
                Divider(
                  indent: 10,
                  endIndent: 10,
                  color: Theme.of(context).colorScheme.primary,
                ),
                if (!parameters.parameters["random_seed"])
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
                              parameters.parameters["seed"] = int.parse(value) ?? 0;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                llamaParamSlider(
                  'n_threads', 
                  parameters.parameters["n_threads"],
                  1.0,
                  128.0,
                  127,
                  (value) => parameters.parameters["n_threads"] = value.round()
                ),
                llamaParamSlider(
                  'n_ctx',
                  parameters.parameters["n_ctx"],
                  1.0,
                  4096.0,
                  4095,
                  (value) => parameters.parameters["n_ctx"] = value.round()
                ),
                llamaParamSlider(
                  'n_batch',
                  parameters.parameters["n_batch"],
                  1.0,
                  4096.0,
                  4095,
                  (value) => parameters.parameters["n_batch"] = value.round()
                ),
                llamaParamSlider(
                  'n_predict',
                  parameters.parameters["n_predict"],
                  1.0,
                  1024.0,
                  1023,
                  (value) => parameters.parameters["n_predict"] = value.round()
                ),
                llamaParamSlider(
                  'n_keep',
                  parameters.parameters["n_keep"],
                  1.0,
                  1024.0,
                  1023,
                  (value) => parameters.parameters["n_keep"] = value.round()
                ),
                llamaParamSlider(
                  'n_prev',
                  parameters.parameters["n_prev"],
                  1.0,
                  1024.0,
                  1023,
                  (value) => parameters.parameters["n_prev"] = value.round()
                ),
                llamaParamSlider(
                  'n_probs',
                  parameters.parameters["n_probs"],
                  0.0,
                  128.0,
                  127,
                  (value) => parameters.parameters["n_probs"] = value.round()
                ),
                llamaParamSlider(
                  'top_k',
                  parameters.parameters["top_k"],
                  1.0,
                  128.0,
                  127,
                  (value) => parameters.parameters["top_k"] = value.round()
                ),
                llamaParamSlider(
                  'top_p',
                  parameters.parameters["top_p"],
                  0.0,
                  1.0,
                  100,
                  (value) => parameters.parameters["top_p"] = value
                ),
                llamaParamSlider(
                  'tfs_z',
                  parameters.parameters["tfs_z"],
                  0.0,
                  1.0,
                  100,
                  (value) => parameters.parameters["tfs_z"] = value
                ),
                llamaParamSlider(
                  'typical_p',
                  parameters.parameters["typical_p"],
                  0.0,
                  1.0,
                  100,
                  (value) => parameters.parameters["typical_p"] = value
                ),
                llamaParamSlider(
                  'temperature',
                  parameters.parameters["temperature"],
                  0.0,
                  1.0,
                  100,
                  (value) => parameters.parameters["temperature"] = value
                ),
                llamaParamSlider(
                  'penalty_last_n',
                  parameters.parameters["penalty_last_n"],
                  0.0,
                  128.0,
                  127,
                  (value) => parameters.parameters["penalty_last_n"] = value.round()
                ),
                llamaParamSlider(
                  'penalty_repeat',
                  parameters.parameters["penalty_repeat"],
                  0.0,
                  2.0,
                  200,
                  (value) => parameters.parameters["penalty_repeat"] = value
                ),
                llamaParamSlider(
                  'penalty_freq',
                  parameters.parameters["penalty_freq"],
                  0.0,
                  1.0,
                  100,
                  (value) => parameters.parameters["penalty_freq"] = value
                ),
                llamaParamSlider(
                  'penalty_present',
                  parameters.parameters["penalty_present"],
                  0.0,
                  1.0,
                  100,
                  (value) => parameters.parameters["penalty_present"] = value
                ),
                llamaParamSlider(
                  'mirostat',
                  parameters.parameters["mirostat"],
                  0.0,
                  128.0,
                  127,
                  (value) => parameters.parameters["mirostat"] = value.round()
                ),
                llamaParamSlider(
                  'mirostat_tau',
                  parameters.parameters["mirostat_tau"],
                  0.0,
                  10.0,
                  100,
                  (value) => parameters.parameters["mirostat_tau"] = value
                ),
                llamaParamSlider(
                  'mirostat_eta',
                  parameters.parameters["mirostat_eta"],
                  0.0,
                  1.0,
                  100,
                  (value) => parameters.parameters["mirostat_eta"] = value
                ),
              ],
            ),
          ),
          if (parameters.busy)
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

