import 'package:flutter/material.dart';
import 'package:maid/settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void _openFileDialog() async {
    String ret = await settings.openFile();
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
                  child: const Text(
                    "Close",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          );
        },
      );
      settings.saveAll();
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
              settings.modelName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            const SizedBox(height: 15.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                  onPressed: _openFileDialog,
                  child: const Text(
                    "Load Model",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                FilledButton(
                  onPressed: () {
                    settings.resetAll(setState);
                  },
                  child: const Text(
                    "Reset All",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15.0),
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
            const SizedBox(height: 20.0),
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
                  child: const Text(
                    "Add Example",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
                  child: const Text(
                    "Remove Example",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
            SwitchListTile(
              title: const Text('memory_f16'),
              value: settings.memory_f16,
              onChanged: (value) {
                setState(() {
                  settings.memory_f16 = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('ignore_eos'),
              value: settings.ignore_eos,
              onChanged: (value) {
                setState(() {
                  settings.ignore_eos = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('instruct'),
              value: settings.instruct,
              onChanged: (value) {
                setState(() {
                  settings.instruct = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('random_prompt'),
              value: settings.random_prompt,
              onChanged: (value) {
                setState(() {
                  settings.random_prompt = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('random_seed'),
              value: settings.random_seed,
              onChanged: (value) {
                setState(() {
                  settings.random_seed = value;
                });
              },
            ),
            const SizedBox(height: 15.0),
            if (!settings.random_seed)
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
                          settings.seed = int.parse(value) ?? 0;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            llamaParamSlider(
              'n_threads', 
              settings.n_threads,
              1.0,
              128.0,
              127,
              (value) => settings.n_threads = value.round()
            ),
            llamaParamSlider(
              'n_ctx',
              settings.n_ctx,
              1.0,
              4096.0,
              4095,
              (value) => settings.n_ctx = value.round()
            ),
            llamaParamSlider(
              'n_batch',
              settings.n_batch,
              1.0,
              4096.0,
              4095,
              (value) => settings.n_batch = value.round()
            ),
            llamaParamSlider(
              'n_predict',
              settings.n_predict,
              1.0,
              1024.0,
              1023,
              (value) => settings.n_predict = value.round()
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
              label: inputValue.round().toString(),
              onChanged: (double value) {
                setState(() {
                  onValueChanged(value);
                });
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(inputValue.round().toString()),
          ),
        ],
      ),
    );
  }
}

