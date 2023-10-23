import 'package:flutter/material.dart';
import 'package:maid/settings.dart';
import 'package:maid/theme.dart';

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
            llamaParamSwitch(
              'memory_f16', settings.memory_f16),
            llamaParamSwitch(
              'ignore_eos', settings.ignore_eos),
            llamaParamSwitch(
              'instruct', settings.instruct),
            llamaParamSwitch(
              'random_prompt', settings.random_prompt),
            const SizedBox(height: 15.0),
            llamaParamTextField(
              'seed (-1 for random)', settings.seedController),
            llamaParamTextField(
              'n_threads', settings.n_threadsController),
            llamaParamTextField(
              'n_ctx', settings.n_ctxController),
            llamaParamTextField(
              'n_batch', settings.n_batchController),
            llamaParamTextField(
              'n_predict', settings.n_predictController),
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

  Widget llamaParamSwitch(String title, bool initialValue) {
    return SwitchListTile(
      title: Text(title),
      value: initialValue,
      onChanged: (value) {
        setState(() {
          switch (title) {
            case 'memory_f16':
              settings.memory_f16 = value;
              break;
            case 'random_prompt':
              settings.random_prompt = value;
              break;
            case 'instruct':
              settings.instruct = value;
              break;
            case 'ignore_eos':
              settings.ignore_eos = value;
              break;
            default:
              break;
          }
          settings.saveBoolToSharedPrefs(title, value);
        });
      },
    );
  }
}

