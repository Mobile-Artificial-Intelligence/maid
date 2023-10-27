import 'package:flutter/material.dart';
import 'package:maid/settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
      settings.saveSharedPreferences();
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
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10.0),
            Text(
              settings.parameters["modelName"],
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
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
                    _storageOperationDialog(settings.loadSettingsFromJson);
                  },
                  child: Text(
                    "Load Settings",
                    style: Theme.of(context).textTheme.labelLarge
                  ),
                ),
                const SizedBox(width: 10.0),
                FilledButton(
                  onPressed: () {
                    _storageOperationDialog(settings.saveSettingsToJson);
                  },
                  child: Text(
                    "Save Settings",
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
                    _storageOperationDialog(settings.loadModelFile);
                  },
                  child: Text(
                    "Load Model",
                    style: Theme.of(context).textTheme.labelLarge
                  ),
                ),
                const SizedBox(width: 10.0),
                FilledButton(
                  onPressed: () {
                    settings.resetAll();
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
              'User alias', settings.userAliasController),
            llamaParamTextField(
              'Response alias', settings.responseAliasController),
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
                      controller: settings.prePromptController,
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
                      settings.examplePromptControllers.add(TextEditingController());
                      settings.exampleResponseControllers.add(TextEditingController());
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
                      settings.examplePromptControllers.removeLast();
                      settings.exampleResponseControllers.removeLast();
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
              (settings.examplePromptControllers.length == settings.exampleResponseControllers.length) ? settings.examplePromptControllers.length : 0,
              (index) => Column(
                children: [
                  llamaParamTextField('Example prompt', settings.examplePromptControllers[index]),
                  llamaParamTextField('Example response', settings.exampleResponseControllers[index]),
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
              value: settings.parameters["instruct"],
              onChanged: (value) {
                setState(() {
                  settings.parameters["instruct"] = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('memory_f16'),
              value: settings.parameters["memory_f16"],
              onChanged: (value) {
                setState(() {
                  settings.parameters["memory_f16"] = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('penalize_nl'),
              value: settings.parameters["penalize_nl"],
              onChanged: (value) {
                setState(() {
                  settings.parameters["penalize_nl"] = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('random_seed'),
              value: settings.parameters["random_seed"],
              onChanged: (value) {
                setState(() {
                  settings.parameters["random_seed"] = value;
                });
              },
            ),
            Divider(
              indent: 10,
              endIndent: 10,
              color: Theme.of(context).colorScheme.primary,
            ),
            if (!settings.parameters["random_seed"])
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
                          settings.parameters["seed"] = int.parse(value) ?? 0;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            llamaParamSlider(
              'n_threads', 
              settings.parameters["n_threads"],
              1.0,
              128.0,
              127,
              (value) => settings.parameters["n_threads"] = value.round()
            ),
            llamaParamSlider(
              'n_ctx',
              settings.parameters["n_ctx"],
              1.0,
              4096.0,
              4095,
              (value) => settings.parameters["n_ctx"] = value.round()
            ),
            llamaParamSlider(
              'n_batch',
              settings.parameters["n_batch"],
              1.0,
              4096.0,
              4095,
              (value) => settings.parameters["n_batch"] = value.round()
            ),
            llamaParamSlider(
              'n_predict',
              settings.parameters["n_predict"],
              1.0,
              1024.0,
              1023,
              (value) => settings.parameters["n_predict"] = value.round()
            ),
            llamaParamSlider(
              'n_keep',
              settings.parameters["n_keep"],
              1.0,
              1024.0,
              1023,
              (value) => settings.parameters["n_keep"] = value.round()
            ),
            llamaParamSlider(
              'n_prev',
              settings.parameters["n_prev"],
              1.0,
              1024.0,
              1023,
              (value) => settings.parameters["n_prev"] = value.round()
            ),
            llamaParamSlider(
              'n_probs',
              settings.parameters["n_probs"],
              0.0,
              128.0,
              127,
              (value) => settings.parameters["n_probs"] = value.round()
            ),
            llamaParamSlider(
              'top_k',
              settings.parameters["top_k"],
              1.0,
              128.0,
              127,
              (value) => settings.parameters["top_k"] = value.round()
            ),
            llamaParamSlider(
              'top_p',
              settings.parameters["top_p"],
              0.0,
              1.0,
              100,
              (value) => settings.parameters["top_p"] = value
            ),
            llamaParamSlider(
              'tfs_z',
              settings.parameters["tfs_z"],
              0.0,
              1.0,
              100,
              (value) => settings.parameters["tfs_z"] = value
            ),
            llamaParamSlider(
              'typical_p',
              settings.parameters["typical_p"],
              0.0,
              1.0,
              100,
              (value) => settings.parameters["typical_p"] = value
            ),
            llamaParamSlider(
              'temperature',
              settings.parameters["temperature"],
              0.0,
              1.0,
              100,
              (value) => settings.parameters["temperature"] = value
            ),
            llamaParamSlider(
              'penalty_last_n',
              settings.parameters["penalty_last_n"],
              0.0,
              128.0,
              127,
              (value) => settings.parameters["penalty_last_n"] = value.round()
            ),
            llamaParamSlider(
              'penalty_repeat',
              settings.parameters["penalty_repeat"],
              0.0,
              2.0,
              200,
              (value) => settings.parameters["penalty_repeat"] = value
            ),
            llamaParamSlider(
              'penalty_freq',
              settings.parameters["penalty_freq"],
              0.0,
              1.0,
              100,
              (value) => settings.parameters["penalty_freq"] = value
            ),
            llamaParamSlider(
              'penalty_present',
              settings.parameters["penalty_present"],
              0.0,
              1.0,
              100,
              (value) => settings.parameters["penalty_present"] = value
            ),
            llamaParamSlider(
              'mirostat',
              settings.parameters["mirostat"],
              0.0,
              128.0,
              127,
              (value) => settings.parameters["mirostat"] = value.round()
            ),
            llamaParamSlider(
              'mirostat_tau',
              settings.parameters["mirostat_tau"],
              0.0,
              10.0,
              100,
              (value) => settings.parameters["mirostat_tau"] = value
            ),
            llamaParamSlider(
              'mirostat_eta',
              settings.parameters["mirostat_eta"],
              0.0,
              1.0,
              100,
              (value) => settings.parameters["mirostat_eta"] = value
            ),
          ],
        ),
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

